function draw_guage(x, y, radius, width, color, val)
    love.graphics.setColor(color)
    love.graphics.setLineWidth(width)
    love.graphics.arc(
        'line',
        'open',
        x, y,
        radius,
        math.pi*2, math.pi*2 - (math.pi/2 * val)
    )
end

function draw_guage_with_background(x, y, radius, width, color, val)
    draw_guage(x, y, radius, width, aly.color_mult(color, 0.5), 1)
    draw_guage(x, y, radius, width, color, val)
end

function draw_meter(warp, weapons, shields)
    draw_guage_with_background(0, WINDOW_HEIGHT, 100, 30, WARP_COLOR, warp)
    draw_guage_with_background(0, WINDOW_HEIGHT, 150, 30, WEAPON_COLOR, weapons)
    draw_guage_with_background(0, WINDOW_HEIGHT, 200, 30, SHIELD_COLOR, shields)
end
