-- see https://love2d.org/wiki/GamepadButton
--     https://love2d.org/wiki/GamepadAxis
function get_gamepad_state(joynum)
    local jbutton = function(button)
        return love.joystick.getJoysticks()[1]:isGamepadDown(button)
    end
    local jaxis = function(ax)
        return love.joystick.getJoysticks()[1]:getGamepadAxis(ax)
    end
    local down = jbutton('dpdown') or jaxis('lefty') > 0.5
    return {
        left      = jbutton('dpleft') or jaxis('leftx') < -0.5,
        right     = jbutton('dpright') or jaxis('leftx') > 0.5,
        forward   = jbutton('a') and not down,
        reverse   = jbutton('a') and down,

        fire      = jbutton('x'),
        alt_fire  = jbutton('y'),
        warp      = jbutton('b'),

        hail      = jbutton('rightshoulder') or jaxis('triggerright') > 0.5,
        nav       = jbutton('leftshoulder') or jaxis('triggerleft') > 0.5
    }
end

-- see https://love2d.org/wiki/KeyConstant
function get_keyboard_state()
    local kdown = love.keyboard.isDown
    return {
        left     = kdown('left'),
        right    = kdown('right'),
        forward  = kdown('up'),
        reverse  = kdown('down'),

        fire     = kdown('lshift'),
        alt_fire = kdown('lctrl'),
        warp     = kdown('w'),

        hail     = kdown('h'),
        nav      = kdown('tab')
    }
end

function or_table(t1, t2)
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

function keyboard_or_gamepad()
    local input = get_keyboard_state()
    if #love.joystick.getJoysticks() > 0 then
        input = or_table(input, get_gamepad_state(1))
    end
    return input
end
