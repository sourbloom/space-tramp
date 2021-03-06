local aly = require('util.aly')
local graphics = require('graphics')
local palette = require('palette')

local hud = {}

function hud.draw_guage(x, y, radius, width, color, val)
    love.graphics.setColor(color)
    love.graphics.setLineWidth(width)
    love.graphics.arc(
        'line',
        'open',
        x, y,
        radius,
        0, -math.pi/2 * val
    )
end

function hud.draw_guage_with_background(x, y, radius, width, color, val, label)
    hud.draw_guage(x, y, radius, width, aly.color_mult(color, 0.5), 1)
    hud.draw_guage(x, y, radius, width, color, val)
    if label then
        x, y = aly.move(
            0,
            love.graphics.getHeight(),
            -math.pi/4,
            radius
        )
        love.graphics.setColor(aly.colors.white)
        aly.print_centered(label, x, y, 0)
    end
end

function hud.draw_meter(warp, weapons, shields)
    local size = graphics.get_window_size()
    hud.draw_guage_with_background(
        0,
        love.graphics.getHeight(),
        graphics.get_window_size()/8,
        graphics.get_window_size()/18,
        palette.warp,
        warp,
        'WARP'
    )
    hud.draw_guage_with_background(
        0,
        love.graphics.getHeight(),
        graphics.get_window_size()/8 + graphics.get_window_size()/18,
        graphics.get_window_size()/18,
        palette.weapon,
        weapons,
        'WEAPON'
    )
    hud.draw_guage_with_background(
        0,
        love.graphics.getHeight(),
        graphics.get_window_size()/8 + graphics.get_window_size()/18*2,
        graphics.get_window_size()/18,
        palette.shield,
        shields,
        'SHIELD'
    )
end

return hud
