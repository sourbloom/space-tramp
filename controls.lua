local aly = require('util.aly')

local controls = {}

-- 8Bitdo SNES30 GamePad
local guid = "05000000c82d00004028000000010000"
love.joystick.setGamepadMapping(guid, 'leftshoulder', 'button', 7)
love.joystick.setGamepadMapping(guid, 'rightshoulder', 'button', 8)
love.joystick.setGamepadMapping(guid, 'leftx', 'axis', 1)
love.joystick.setGamepadMapping(guid, 'lefty', 'axis', 2)
love.joystick.setGamepadMapping(guid, 'a', 'button', 2)
love.joystick.setGamepadMapping(guid, 'b', 'button', 1)
love.joystick.setGamepadMapping(guid, 'x', 'button', 5)
love.joystick.setGamepadMapping(guid, 'y', 'button', 4)

-- see https://love2d.org/wiki/GamepadButton
--     https://love2d.org/wiki/GamepadAxis
function controls.get_gamepad_state(joynum)
    local jbutton = function(button)
        return love.joystick.getJoysticks()[joynum]:isGamepadDown(button)
    end
    local jaxis = function(ax)
        return love.joystick.getJoysticks()[joynum]:getGamepadAxis(ax)
    end
    local down = jbutton('dpdown') or jaxis('lefty') > 0.5
    return {
        left      = jbutton('dpleft') or jaxis('leftx') < -0.5,
        right     = jbutton('dpright') or jaxis('leftx') > 0.5,
        forward   = jbutton('a') and not down,
        reverse   = jbutton('a') and down,

        fire      = jbutton('x'),
        alt_fire  = jbutton('b'),
        warp      = jbutton('y'),

        hail      = jbutton('rightshoulder') or jaxis('triggerright') > 0.5,
        nav       = jbutton('leftshoulder') or jaxis('triggerleft') > 0.5
    }
end

-- see https://love2d.org/wiki/KeyConstant
function controls.get_keyboard_state()
    local kdown = love.keyboard.isDown
    local input = {
        left     = kdown('left'),
        right    = kdown('right'),
        forward  = kdown('up'),
        reverse  = kdown('down'),

        fire     = kdown('lshift') or kdown('rshift'),
        alt_fire = kdown('lctrl') or kdown('rctrl'),
        warp     = kdown('w'),

        hail     = kdown('h'),
        nav      = kdown('tab')
    }
    return input
end

function controls.get_touch_state()
    local input = {}
    for _, id in ipairs(love.touch.getTouches()) do
        local x, y = love.touch.getPosition(id)
        if y < love.graphics.getHeight() / 2 then
            if x > love.graphics.getWidth() - love.graphics.getWidth() / 5 then
                input.warp = true
            elseif x < love.graphics.getWidth() / 5 then
                input.nav = true
            else
                input.forward = true
            end
        else
            if x > love.graphics.getWidth() / 2 then
                input.right = true
            else
                input.left = true
            end
        end
    end
    return input
end

function controls.or_table(t1, t2)
    local result = aly.copy(t1)
    for k, v in pairs(t2) do
        if result[k] then
            result[k] = result[k] or v
        else
            result[k] = v
        end
    end
    return result
end

function controls.player_input(ship)
    local input = controls.get_keyboard_state()

    for i = 1, love.joystick.getJoystickCount() do
        input = controls.or_table(input, controls.get_gamepad_state(i))
    end

    input = controls.or_table(input, controls.get_touch_state())

    return input
end

return controls
