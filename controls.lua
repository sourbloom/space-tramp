-- see https://love2d.org/wiki/GamepadButton
--     https://love2d.org/wiki/GamepadAxis
function get_gamepad_state(joynum)
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
        alt_fire  = jbutton('y'),
        warp      = jbutton('b'),

        hail      = jbutton('rightshoulder') or jaxis('triggerright') > 0.5,
        nav       = jbutton('leftshoulder') or jaxis('triggerleft') > 0.5
    }
end

-- see https://love2d.org/wiki/KeyConstant
function get_keyboard_state()
    local kdown = love.keyboard.isDown
    local input = {
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
    return input
end

function get_touch_state()
    local input = {}
    for _, id in ipairs(love.touch.getTouches()) do
        local x, y = love.touch.getPosition(id)
        if y < WINDOW_HEIGHT / 2 then
            if x > WINDOW_WIDTH - WINDOW_WIDTH / 5 then
                input.warp = true
            elseif x < WINDOW_WIDTH / 5 then
                input.nav = true
            else
                input.forward = true
            end
        else
            if x > WINDOW_WIDTH / 2 then
                input.right = true
            else
                input.left = true
            end
        end
    end
    return input
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
    input = or_table(input, get_touch_state())
    return input
end
