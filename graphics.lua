function draw_spinny(thing)
    turtle:start(thing.x, thing.y, thing.angle)
    turtle:pen_color(aly.colors.antiquewhite)
    turtle:pen_width(3)

    local size = 50

    turtle:forward(size*2)
    turtle:back(size*2)
    for i = 0, size do
        turtle:forward(i)
        turtle:right(math.pi/6)
    end
end

function draw_enterprise(thing, color, head_radius, body_length, engine_length, engine_dist, body_thickness)
    turtle:start(thing.x, thing.y, thing.angle)
    turtle:pen_color(color)
    turtle:pen_width(body_thickness)

    turtle:forward(body_length / 2)

    -- body
    turtle:circle(head_radius)
    turtle:right(math.pi)
    turtle:forward(body_length)

    -- left engine
    turtle:right(math.pi / 2)
    turtle:forward(engine_dist / 2)
    turtle:right(math.pi / 2)
    turtle:forward(engine_length / 2)
    turtle:back(engine_length)
    turtle:forward(engine_length / 2)
    turtle:right(math.pi / 2)

    turtle:forward(engine_dist)

    -- right engine
    turtle:left(math.pi / 2)
    turtle:forward(engine_length / 2)
    turtle:back(engine_length)
    turtle:forward(engine_length / 2)
end

function clamp_color(color)
    return aly.clamp(color, 0, 255)
end

function normal_enterprise(thing)
    local color = aly.colors.lightslategray
    color[1] = clamp_color(color[1])
    color[2] = clamp_color(color[2])
    color[3] = clamp_color(color[3])
    local head_radius = 14
    local body_length = 25
    local engine_length = 16
    local engine_dist = 26
    local body_thickness = 6
    draw_enterprise(
        thing,
        color,
        head_radius,
        body_length,
        engine_length,
        engine_dist,
        body_thickness
    )
end

function gen_draw_random_enterprise()
    local color = aly.colors.lightslategray
    color[1] = clamp_color(color[1] + math.random(-50, 50))
    color[2] = clamp_color(color[2] + math.random(-50, 50))
    color[3] = clamp_color(color[3] + math.random(-50, 50))
    local head_radius = 14 + math.random(-3, 3)
    local body_length = 25 + math.random(-3, 3)
    local engine_length = 16 + math.random(-3, 3)
    local engine_dist = 26 + math.random(-5, 5)
    local body_thickness = 6 + math.random(-2, 2)
    return function(thing)
        draw_enterprise(
            thing,
            color,
            head_radius,
            body_length,
            engine_length,
            engine_dist,
            body_thickness
        )
    end
end

function draw_triangle(thing)
    turtle:start(thing.x, thing.y, thing.angle)
    turtle:pen_color(aly.colors.lightslategray)
    turtle:pen_width(3)

    turtle:pen_up()
    turtle:forward(30)
    turtle:pen_down()
    turtle:right(5*math.pi/6)
    turtle:forward(60)
    turtle:back(60)
    turtle:left(5*math.pi/6)
    turtle:left(5*math.pi/6)
    turtle:forward(60)
    turtle:back(60)
    turtle:right(5*math.pi/6)
    turtle:pen_up()
    turtle:back(40)
    turtle:right(math.pi/4)
    turtle:pen_down()
    turtle:forward(20)
    turtle:back(20)
    turtle:left(math.pi/4)
    turtle:left(math.pi/4)
    turtle:forward(20)
end

function draw_warp_meter(ship)
    if ship.warp_charge > 0 then
        love.graphics.setColor(aly.colors.dodgerblue)
        love.graphics.setLineWidth(2 + 5 * ship.warp_charge)
        love.graphics.arc(
            'line',
            'open',
            math.floor(ship.x), math.floor(ship.y),
            60,
            ship.angle + math.pi,
            ship.angle + math.pi + math.pi * ship.warp_charge
        )
        love.graphics.arc(
            'line',
            'open',
            math.floor(ship.x), math.floor(ship.y),
            60,
            ship.angle + math.pi,
            ship.angle + math.pi - math.pi * ship.warp_charge
        )
    end
end

function make_stars()
    local stars = {}
    for i = 1, 50 do
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

STAR_WARP_LINE_LENGTH = 150

function draw_stars(stars, camera)
    for i, star in ipairs(stars) do
        love.graphics.setColor(star.color)
        local x = ((star.x - (camera.x / (-star.r + 5))) % (WINDOW_WIDTH + STAR_WARP_LINE_LENGTH * 2)) - STAR_WARP_LINE_LENGTH
        local y = ((star.y - (camera.y / (-star.r + 5))) % (WINDOW_HEIGHT + STAR_WARP_LINE_LENGTH * 2)) - STAR_WARP_LINE_LENGTH
        if player.warp_speed > 0.01 then
            local x2, y2 = aly.move(
                x, y,
                player.angle + math.pi,
                STAR_WARP_LINE_LENGTH * (player.warp_speed / WARP_SPEED)
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
