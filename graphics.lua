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

function draw_enterprise(thing)
    local head_radius = 14
    local body_length = 25
    local engine_length = 16
    local engine_dist = 26
    local body_thickness = 6

    turtle:start(thing.x, thing.y, thing.angle)
    turtle:pen_color(aly.colors.lightslategray)
    turtle:pen_width(body_thickness)

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

draw_ship = draw_enterprise

function draw_warp_meter(ship)
    if ship.warp_charge > 0 and ship.warp_charge < 1.0 then
        love.graphics.setColor(aly.colors.blueviolet)
        love.graphics.setLineWidth(5)
        love.graphics.arc(
            'line',
            'open',
            math.floor(ship.x), math.floor(ship.y),
            20,
            ship.angle, ship.angle - math.pi * 2 * ship.warp_charge
        )
    end
end

function make_stars()
    local stars = {}
    for i = 1, 100 do
        local hue = math.random(100, 255)
        table.insert(stars, {
            x = math.random(0, WINDOW_WIDTH),
            y = math.random(0, WINDOW_HEIGHT),
            r = 1 + math.random() * 3,
            color = { hue, hue, hue }
        })
    end
    return stars
end

function draw_stars(stars, camera)
    for i, star in ipairs(stars) do
        love.graphics.setColor(star.color)
        love.graphics.circle(
            'fill',
            (star.x - (camera.x / (-star.r + 5))) % WINDOW_WIDTH,
            (star.y - (camera.y / (-star.r + 5))) % WINDOW_HEIGHT,
            star.r
        )
    end
end
