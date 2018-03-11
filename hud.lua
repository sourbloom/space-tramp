function draw_guage(x, y, radius, width, color, val)
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

function draw_guage_with_background(x, y, radius, width, color, val)
    draw_guage(x, y, radius, width, aly.color_mult(color, 0.5), 1)
    draw_guage(x, y, radius, width, color, val)
end

function draw_meter(warp, weapons, shields)
    draw_guage_with_background(0, WINDOW_HEIGHT, 100, 30, WARP_COLOR, warp)
    draw_guage_with_background(0, WINDOW_HEIGHT, 150, 30, WEAPON_COLOR, weapons)
    draw_guage_with_background(0, WINDOW_HEIGHT, 200, 30, SHIELD_COLOR, shields)
    -- draw_guage_with_background(0, WINDOW_HEIGHT, 250, 30, aly.colors.white, 0.8)
    local x, y
    love.graphics.setColor(aly.colors.black)
    x, y = aly.move(0, WINDOW_HEIGHT, -math.pi/4, 110)
    aly.print_centered('warp', x, y, math.pi/4)
    x, y = aly.move(0, WINDOW_HEIGHT, -math.pi/4, 170)
    aly.print_centered('weapons', x, y, math.pi/4)
    x, y = aly.move(0, WINDOW_HEIGHT, -math.pi/4, 215)
    aly.print_centered('shield', x, y, math.pi/4)
end
