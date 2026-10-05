-- Runtime adjustments to Mr. Rescue for the Miyoo Mini Plus. Loaded after the
-- game's own main.lua, so everything here replaces or wraps game functions;
-- the game's source files themselves stay unmodified.

local M = require("miyoo.m2d")
local Shim = require("miyoo.shim")
local lg = love.graphics

---------------------------------------------------------------------------
-- screen: the game always draws at 1x (256x200) and mini2d scales it
---------------------------------------------------------------------------
-- config.miyoo_screen: 0 = SHARP (2x, crisp pixels, small border),
-- 1 = FIT (full height, keeps proportions), 2 = STRETCH (whole screen)
local SCREEN_NAMES = { [0] = "SHARP", [1] = "FIT", [2] = "STRETCH" }

local function applyScreen()
  M.m2d_set_present_mode(config.miyoo_screen or 1)
end

local realLoadConfig = loadConfig
function loadConfig()
  realLoadConfig()
  config.scale = 1
  config.fullscreen = 0
  if SCREEN_NAMES[config.miyoo_screen or -1] == nil then config.miyoo_screen = 1 end
  applyScreen()
end

function setMode()
  fs_translatex, fs_translatey = 0, 0
  lg.setScissor()
  applyScreen()
end

function toggleVSync() end

---------------------------------------------------------------------------
-- input: which button layout is active (see miyoo/shim.lua)
---------------------------------------------------------------------------
function Shim.inPlay()
  return state == STATE_INGAME and ingame_state == INGAME_ACTIVE
end

-- Select on the main menu would quit straight away; use QUIT or Select+Start
local realMainKey = mainmenu.keypressed
function mainmenu.keypressed(k, uni)
  if k == "escape" then return end
  return realMainKey(k, uni)
end

---------------------------------------------------------------------------
-- Options: screen mode, volumes and the button layout
-- (the original scale/fullscreen/vsync/keyboard/joystick pages don't apply)
---------------------------------------------------------------------------
local ITEMS = 4 -- SCREEN, SOUND VOL, MUSIC VOL, BACK

function options.enter()
  state = STATE_OPTIONS
  options.selection = 1
end

function options.update(dt)
  updateKeys()
end

function options.draw()
  lg.setFont(font.bold)
  drawBox(40, 30, 176, 150)
  lg.printf("OPTIONS", 0, 16, WIDTH, "center")
  lg.print("SCREEN:", 65, 42)       lg.print(SCREEN_NAMES[config.miyoo_screen], 152, 42)
  lg.print("SOUND VOL:", 65, 55)    lg.print(math.floor(config.sfx_volume * 10 + 0.01), 152, 55)
  lg.print("MUSIC VOL:", 65, 68)    lg.print(math.floor(config.music_volume * 10 + 0.01), 152, 68)
  lg.print("BACK", 65, 81)
  lg.print(">", 52, 29 + options.selection * 13)

  lg.setColor(1, 1, 1, 0.55)
  lg.rectangle("fill", 52, 97, 152, 1)
  lg.setColor(1, 1, 1, 1)
  lg.printf("CONTROLS", 0, 104, WIDTH, "center")
  lg.print("B", 58, 120)          lg.print("JUMP", 76, 120)
  lg.print("Y", 132, 120)         lg.print("SHOOT", 150, 120)
  lg.print("A", 58, 133)          lg.print("GRAB / THROW", 76, 133)
  lg.print("UP/DOWN", 58, 146)    lg.print("LADDERS", 132, 146)
  lg.print("START", 58, 159)      lg.print("PAUSE", 132, 159)
end

local function change(dir)
  local s = options.selection
  if s == 1 then
    config.miyoo_screen = (config.miyoo_screen + dir) % 3
    applyScreen()
  elseif s == 2 then
    config.sfx_volume = cap(config.sfx_volume + dir * 0.1, 0, 1)
    love.audio.tags.sfx.setVolume(config.sfx_volume)
  elseif s == 3 then
    config.music_volume = cap(config.music_volume + dir * 0.1, 0, 1)
    love.audio.tags.music.setVolume(config.music_volume)
  else
    return
  end
  playSound("blip")
end

local function leave()
  playSound("confirm")
  saveConfig()
  mainmenu.enter()
end

function options.keypressed(k, uni)
  if k == "down" then
    options.selection = wrap(options.selection + 1, 1, ITEMS)
    playSound("blip")
  elseif k == "up" then
    options.selection = wrap(options.selection - 1, 1, ITEMS)
    playSound("blip")
  elseif k == "left" then
    change(-1)
  elseif k == "right" then
    change(1)
  elseif k == "escape" then
    leave()
  end
end

function options.action(k)
  if k == "jump" or k == "pause" then -- A / Start
    if options.selection == ITEMS then leave() else change(1) end
  elseif k == "action" then           -- B
    leave()
  end
end
