-- Installs Miyoo replacements for the LÖVE modules that need a window/GPU,
-- and turns the handheld's buttons into a keyboard + virtual gamepad.
-- Must be required before any Mr. Rescue code.

local ffi = require("ffi")
local M = require("miyoo.m2d")
local G = require("miyoo.graphics")

-- Mr. Rescue's native resolution; mini2d scales it to the screen on present
local GAME_W, GAME_H = 256, 200
local noop = function() end

G._init(GAME_W, GAME_H)
love.graphics = G
package.loaded["love.graphics"] = G

---------------------------------------------------------------------------
-- love.window
---------------------------------------------------------------------------
local W = {}
local title = "Mr. Rescue"
local modeFlags = { fullscreen = false, fullscreentype = "desktop", vsync = 1, msaa = 0, stencil = true, depth = 0,
  resizable = false, borderless = true, centered = true, display = 1, minwidth = 1, minheight = 1, highdpi = false,
  refreshrate = 60, x = 0, y = 0, usedpiscale = false }
function W.getMode() return GAME_W, GAME_H, modeFlags end
function W.setMode() return true end
function W.updateMode() return true end
function W.getDesktopDimensions() return GAME_W, GAME_H end
function W.getPosition() return 0, 0, 1 end
function W.setPosition() end
function W.getFullscreen() return false, "desktop" end
function W.setFullscreen() return true end
function W.getFullscreenModes() return { { width = GAME_W, height = GAME_H } } end
function W.setTitle(t) title = t end
function W.getTitle() return title end
function W.setIcon() return true end
function W.showMessageBox(t, msg) print("[messagebox] " .. tostring(t) .. ": " .. tostring(msg)); return 1 end
function W.isOpen() return true end
function W.close() end
function W.hasFocus() return true end
function W.hasMouseFocus() return false end
function W.isVisible() return true end
function W.getDisplayCount() return 1 end
function W.getDPIScale() return 1 end
function W.toPixels(v, v2) if v2 then return v, v2 end return v end
function W.fromPixels(v, v2) if v2 then return v, v2 end return v end
function W.setVSync() end
function W.getVSync() return 1 end
function W.isDisplaySleepEnabled() return false end
function W.setDisplaySleepEnabled() end
love.window = W
package.loaded["love.window"] = W

local Mouse = {}
for _, n in ipairs({ "setVisible", "setGrabbed", "setRelativeMode", "setCursor", "setPosition" }) do Mouse[n] = noop end
function Mouse.getPosition() return 0, 0 end
function Mouse.isDown() return false end
function Mouse.isVisible() return false end
love.mouse = Mouse
package.loaded["love.mouse"] = Mouse

---------------------------------------------------------------------------
-- buttons
---------------------------------------------------------------------------
-- evdev codes of the Miyoo Mini Plus
local BTN = { UP = 103, DOWN = 108, LEFT = 105, RIGHT = 106, A = 57, B = 29, X = 42, Y = 56,
  L1 = 18, R1 = 20, L2 = 15, R2 = 14, START = 28, SELECT = 97, MENU = 1 }

-- D-pad and Select/Menu arrive as keyboard keys (menus and ladders read those)
local KEYMAP = {
  [BTN.UP] = "up", [BTN.DOWN] = "down", [BTN.LEFT] = "left", [BTN.RIGHT] = "right",
  [BTN.SELECT] = "escape", [BTN.MENU] = "escape",
}

-- Face buttons become buttons of a virtual gamepad, using Mr. Rescue's default
-- pad layout: 1 = jump, 2 = action (grab/throw), 3 = shoot, 8 = pause.
-- In menus the game treats "jump" as confirm and "action" as back, so A/B
-- swap roles there to follow the OnionOS convention (A = OK, B = back).
local JUMP, ACTION, SHOOT, PAUSE = 1, 2, 3, 8
local PLAY_MAP = { [BTN.B] = JUMP, [BTN.A] = ACTION, [BTN.Y] = SHOOT, [BTN.X] = SHOOT,
  [BTN.L1] = SHOOT, [BTN.R1] = SHOOT, [BTN.START] = PAUSE }
local MENU_MAP = { [BTN.A] = JUMP, [BTN.B] = ACTION, [BTN.Y] = SHOOT, [BTN.X] = SHOOT, [BTN.START] = PAUSE }

-- set by miyoo.patches: true while the player is in control during a level
local Shim = { inPlay = function() return false end }

local down = {}          -- keyboard keys held
local padDown = {}       -- virtual pad buttons held (count, several buttons can map to one)
local codeDown = {}      -- raw evdev codes held
local codePad = {}       -- pad button a raw code was mapped to when pressed

local K = {}
function K.isDown(...)
  for i = 1, select("#", ...) do
    if down[select(i, ...)] then return true end
  end
  return false
end
K.isScancodeDown = K.isDown
K.setTextInput = noop
function K.hasTextInput() return false end
K.setKeyRepeat = noop
function K.hasKeyRepeat() return false end
function K.getScancodeFromKey(k) return k end
function K.getKeyFromScancode(k) return k end
function K.hasScreenKeyboard() return false end
function K.isModifierActive() return false end
love.keyboard = K
package.loaded["love.keyboard"] = K

-- one virtual gamepad
local Pad = {}
Pad.__index = Pad
function Pad:isDown(...)
  for i = 1, select("#", ...) do
    if (padDown[select(i, ...)] or 0) > 0 then return true end
  end
  return false
end
function Pad:getAxes() return 0, 0 end
function Pad:getAxis() return 0 end
function Pad:getAxisCount() return 2 end
function Pad:getButtonCount() return 12 end
function Pad:getHat() return "c" end
function Pad:getHatCount() return 0 end
function Pad:getName() return "Miyoo Mini Plus" end
function Pad:getID() return 1, 1 end
function Pad:isGamepad() return false end
function Pad:isConnected() return true end
function Pad:isVibrationSupported() return false end
function Pad:setVibration() return false end
local pad = setmetatable({}, Pad)
love.joystick = {
  getJoysticks = function() return { pad } end,
  getJoystickCount = function() return 1 end,
  loadGamepadMappings = noop,
  setGamepadMapping = function() return false end,
}
package.loaded["love.joystick"] = love.joystick

local code, value = ffi.new("int[1]"), ffi.new("int[1]")
local function pollButtons()
  while M.m2d_poll_key(code, value) == 1 do
    local c, v = code[0], value[0]
    if v ~= 2 then -- ignore autorepeat
      local pressed = v == 1
      codeDown[c] = pressed
      -- Select + Start or Menu + Start quits
      if pressed and c == BTN.START and (codeDown[BTN.SELECT] or codeDown[BTN.MENU]) then
        love.event.push("quit")
      end
      local key = KEYMAP[c]
      if key then
        if pressed and not down[key] then
          down[key] = true
          love.event.push("keypressed", key, key, false)
        elseif not pressed and down[key] then
          down[key] = nil
          love.event.push("keyreleased", key, key)
        end
      else
        if pressed then
          local b = (Shim.inPlay() and PLAY_MAP or MENU_MAP)[c]
          if b and not codePad[c] then
            codePad[c] = b
            padDown[b] = (padDown[b] or 0) + 1
            love.event.push("joystickpressed", 0, b)
          end
        else
          local b = codePad[c]
          if b then
            codePad[c] = nil
            padDown[b] = math.max(0, (padDown[b] or 1) - 1)
            love.event.push("joystickreleased", 0, b)
          end
        end
      end
    end
  end
end
-- held buttons whose meaning changes between menu and play (e.g. A held while
-- the level starts) are released so they can't stick
function Shim.releaseAll()
  for c, b in pairs(codePad) do
    padDown[b] = 0
    codePad[c] = nil
  end
end

local realPump = love.event.pump
love.event.pump = function(...)
  realPump(...)
  pollButtons()
end

---------------------------------------------------------------------------
-- love.audio / love.sound: real OpenAL audio when a device opens, else silent stubs
---------------------------------------------------------------------------
-- The Miyoo has no ALSA; OnionOS exposes sound through OSS (/dev/dsp) when
-- libpadsp.so is preloaded (launch.sh). OpenAL Soft's OSS backend uses that.
-- MR_NOSOUND=1 forces the silent stubs.
local function tryRealAudio()
  if os.getenv("MR_NOSOUND") then return false, "MR_NOSOUND set" end
  local ok, snd = pcall(require, "love.sound")
  if not ok then return false, "love.sound: " .. tostring(snd) end
  local ok2, aud = pcall(require, "love.audio")
  if not ok2 then return false, "love.audio: " .. tostring(aud) end
  -- LÖVE quietly switches to a "null" device when OpenAL can't open one; a
  -- null source refuses to play, which is how we notice.
  local okPlay, played = pcall(function()
    local sd = snd.newSoundData(256, 22050, 16, 1)
    local src = aud.newSource(sd, "static")
    src:setVolume(0)
    local r = src:play()
    src:stop()
    src:release()
    return r
  end)
  if not (okPlay and played) then
    package.loaded["love.audio"], package.loaded["love.sound"] = nil, nil
    return false, "no playback device (" .. tostring(played) .. ")"
  end
  love.sound, love.audio = snd, aud
  return true, "OpenAL"
end

local function installSilentAudio()
  -- like real LÖVE objects, all sources share one metatable holding the
  -- methods (Mr. Rescue's slam.lua patches play/stop on it)
  local proto = newproxy(true)
  local Source = getmetatable(proto)
  Source.__index = Source
  Source.__tostring = function() return "Source" end
  local srcState = setmetatable({}, { __mode = "k" })
  local function makeSource(stype)
    local u = newproxy(proto)
    srcState[u] = { volume = 1, looping = false, stype = stype or "static", pitch = 1 }
    return u
  end
  function Source:play() srcState[self].playing = true; return true end
  function Source:stop() srcState[self].playing = false end
  function Source:pause() srcState[self].playing = false end
  function Source:isPlaying() return srcState[self].playing == true end
  function Source:isStopped() return not srcState[self].playing end
  function Source:setVolume(v) srcState[self].volume = v end
  function Source:getVolume() return srcState[self].volume end
  function Source:setLooping(l) srcState[self].looping = l end
  function Source:isLooping() return srcState[self].looping end
  function Source:setPitch(p) srcState[self].pitch = p end
  function Source:getPitch() return srcState[self].pitch end
  function Source:seek() end
  function Source:tell() return 0 end
  function Source:clone() return makeSource(srcState[self].stype) end
  function Source:getType() return srcState[self].stype end
  function Source:setPosition() end
  function Source:setRelative() end
  function Source:release() return true end
  function Source:typeOf(t) return t == "Source" or t == "Object" end
  function Source:type() return "Source" end

  local A = {}
  A.newSource = function(_, stype) return makeSource(stype) end
  A.play = function(s) if s and s.play then s:play() end end
  A.stop = function(s) if s and s.stop then s:stop() end end
  A.pause = function() return {} end
  local masterVolume = 1
  A.setVolume = function(v) masterVolume = v end
  A.getVolume = function() return masterVolume end
  A.getActiveSourceCount = function() return 0 end
  A.setPosition = noop
  A.setDistanceModel = noop
  A.setMixWithSystem = function() return false end
  love.audio = A
  package.loaded["love.audio"] = A
  love.sound = { newSoundData = function() return {} end, newDecoder = function() return {} end }
  package.loaded["love.sound"] = love.sound
end

local realAudio, audioInfo = tryRealAudio()
if realAudio then
  print("[audio] playing through " .. audioInfo)
else
  print("[audio] silent: " .. audioInfo)
  installSilentAudio()
end

if love.system then
  love.system.getClipboardText = function() return "" end
  love.system.setClipboardText = noop
  love.system.openURL = function() return false end
end

-- the error screen needs love.event.wait (pumps + our buttons)
if love.event and love.event.wait then
  love.event.wait = function()
    love.timer.sleep(0.05)
    love.event.pump()
    for n, a, b, c, d, e, f in love.event.poll() do return n, a, b, c, d, e, f end
  end
end

package.loaded["miyoo.shim"] = Shim
return Shim
