function draw_spinny(ship)
    local t = new_turtle(ship.physics.x, ship.physics.y, ship.physics.angle)
    t.pen_color(aly.colors.antiquewhite)
    t.pen_width(3)

    local size = 50

    t.forward(size*2)
    t.back(size*2)
    for i = 0, size do
        t.forward(i)
        t.right(math.pi/6)
    end
end

function draw_enterprise(ship, color, head_radius, body_length, engine_length, engine_dist, body_thickness)
    local t = new_turtle(ship.physics.x, ship.physics.y, ship.physics.angle)
    t.pen_color(color)
    t.pen_width(body_thickness)

    t.forward(body_length / 2)

    -- body
    t.circle(head_radius)
    t.right(math.pi)
    t.forward(body_length)

    t.mirror(true)

    -- engines
    t.right(math.pi / 2)
    t.forward(engine_dist / 2)
    t.right(math.pi / 2)
    t.forward(engine_length / 2)
    t.back(engine_length)
    t.forward(engine_length / 2)
    t.right(math.pi / 2)
end

function clamp_color(color)
    return aly.clamp(color, 0, 255)
end

function normal_enterprise(ship)
    local color = aly.colors.lightslategray
    local head_radius = 14
    local body_length = 25
    local engine_length = 16
    local engine_dist = 26
    local body_thickness = 6
    draw_enterprise(
        ship,
        color,
        head_radius,
        body_length,
        engine_length,
        engine_dist,
        body_thickness
    )
end

function gen_draw_random_enterprise()
    local color = aly.copy(aly.colors.lightslategray)
    color[1] = clamp_color(color[1] + math.random(-50, 50))
    color[2] = clamp_color(color[2] + math.random(-50, 50))
    color[3] = clamp_color(color[3] + math.random(-50, 50))
    local head_radius = 14 + math.random(0, 8)
    local body_length = 25 + math.random(-2, 10)
    local engine_length = 16 + math.random(-5, 5)
    local engine_dist = 26 + math.random(-5, 5)
    local body_thickness = 6 + math.random(-4, 4)
    return function(ship)
        draw_enterprise(
            ship,
            color,
            head_radius,
            body_length,
            engine_length,
            engine_dist,
            body_thickness
        )
    end
end

function draw_fancy(ship)
    local t = new_turtle(ship.physics.x, ship.physics.y, ship.physics.angle)
    t.pen_color(aly.colors.green)
    t.pen_width(3)

    t.pen(false)
    -- t.back(30)
    t.push()
    t.forward(30)
    t.pen(true)
    t.mirror(true)
    t.right(math.pi*5/6)
    t.forward(30)
    t.left(math.pi/7)
    t.forward(20)
    t.left(math.pi/3)
    t.forward(10)
    t.right(math.pi*3/4)
    t.forward(20)
    t.pop()
end

function draw_triangle(ship)
    local t = new_turtle(ship.physics.x, ship.physics.y, ship.physics.angle)
    t.pen_color(aly.colors.red)
    t.pen_width(3)

    t.pen(false)
    t.forward(30)
    t.pen(true)
    t.right(5*math.pi/6)
    t.forward(60)
    t.back(60)
    t.left(5*math.pi/6)
    t.left(5*math.pi/6)
    t.forward(60)
    t.back(60)
    t.right(5*math.pi/6)
    t.pen(false)
    t.back(40)
    t.right(math.pi/4)
    t.pen(true)
    t.forward(20)
    t.back(20)
    t.left(math.pi/4)
    t.left(math.pi/4)
    t.forward(20)
end

function draw_test_ship(ship)
    local t = new_turtle(ship.physics.x, ship.physics.y, ship.physics.angle)
    t.pen_color(aly.colors.lightslategray)
    t.pen_width(3)

    t.back(30)
    t.forward(60)
    t.mirror(true)
    for i = 1, 10 do
        t.right(math.pi/8)
        t.forward(20)
    end
end

function draw_warp_meter1(ship)
    if ship.warp.charge > 0 then
        love.graphics.setColor(WARP_COLOR)
        love.graphics.setLineWidth(2 + 2 * ship.warp.charge)
        love.graphics.arc(
            'line',
            'open',
            math.floor(ship.physics.x), math.floor(ship.physics.y),
            60,
            ship.physics.angle + math.pi,
            ship.physics.angle + math.pi + math.pi * ship.warp.charge
        )
        love.graphics.arc(
            'line',
            'open',
            math.floor(ship.physics.x), math.floor(ship.physics.y),
            60,
            ship.physics.angle + math.pi,
            ship.physics.angle + math.pi - math.pi * ship.warp.charge
        )
    end
end

function draw_warp_meter2(ship)
    if ship.warp.charge > 0 and ship.warp.charge < 1.0 then
        love.graphics.setColor(aly.colors.dodgerblue)
        love.graphics.setLineWidth(10)
        love.graphics.arc(
            'line',
            'open',
            math.floor(ship.physics.x), math.floor(ship.physics.y),
            60,
            ship.physics.angle,
            ship.physics.angle + math.pi * 2 * ship.warp.charge
        )
    end
end

draw_warp_meter = draw_warp_meter2

function make_stars()
    local stars = {}
    for i = 1, 90 do
        local hue = math.random(100, 255)
        table.insert(stars, {
            x = math.random(0, WINDOW_WIDTH + STAR_WARP_LINE_LENGTH * 2),
            y = math.random(0, WINDOW_HEIGHT + STAR_WARP_LINE_LENGTH * 2),
            r = 1 + math.random() * 3,
            color = { hue, hue, hue }
        })
    end
    return stars
end

function draw_stars(stars, camera)
    for i, star in ipairs(stars) do
        love.graphics.setColor(star.color)
        local x = ((star.x - (camera.x / (-star.r + 5))) % (WINDOW_WIDTH + STAR_WARP_LINE_LENGTH * 2)) - STAR_WARP_LINE_LENGTH
        local y = ((star.y - (camera.y / (-star.r + 5))) % (WINDOW_HEIGHT + STAR_WARP_LINE_LENGTH * 2)) - STAR_WARP_LINE_LENGTH
        if player.warp.speed > 0.01 then
            local x2, y2 = aly.move(
                x, y,
                player.physics.angle + math.pi,
                STAR_WARP_LINE_LENGTH * (player.warp.speed / WARP_SPEED)
            )
            love.graphics.setLineWidth(star.r)
            love.graphics.line(x, y, x2, y2)
        else
            love.graphics.circle('fill', x, y, star.r)
        end
    end
end

function draw_bullet(bullet)
    if not bullet.dead then
        love.graphics.setColor(aly.colors.red)
        love.graphics.circle('fill', bullet.x, bullet.y, 10)
    end
end
