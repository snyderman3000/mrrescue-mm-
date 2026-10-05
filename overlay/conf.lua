-- Miyoo Mini Plus conf: Mr. Rescue's settings, without the window/GPU/input
-- modules (miyoo/shim.lua replaces them; audio is opened there too).
function love.conf(t)
  t.identity = "mrrescue"
  t.appendidentity = false
  t.version = "11.5"
  t.console = false
  t.gammacorrect = false
  t.accelerometerjoystick = false

  t.window = nil
  t.modules.window = false
  t.modules.graphics = false
  t.modules.audio = false
  t.modules.sound = false
  t.modules.joystick = false
  t.modules.keyboard = false
  t.modules.mouse = false
  t.modules.touch = false
  t.modules.video = false
  t.modules.physics = false

  t.modules.event = true
  t.modules.image = true
  t.modules.font = true
  t.modules.math = true
  t.modules.system = true
  t.modules.thread = true
  t.modules.timer = true
  t.modules.data = true
end
