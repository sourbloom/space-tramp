local aly = require('util.aly')
local turtle = require('util.turtle')
local palette = require('palette')

function draw_spinny(ship)
    local t = turtle.new(ship.physics.x, ship.physics.y, ship.physics.angle)
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
    local t = turtle.new(ship.physics.x, ship.physics.y, ship.physics.angle)
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

function get_window_size()
    return math.min(love.graphics.getWidth(), love.graphics.getHeight())
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
    local t = turtle.new(ship.physics.x, ship.physics.y, ship.physics.angle)
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
    local t = turtle.new(ship.physics.x, ship.physics.y, ship.physics.angle)
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
    local t = turtle.new(ship.physics.x, ship.physics.y, ship.physics.angle)
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
        love.graphics.setColor(palette.warp)
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
        love.graphics.setColor(palette.warp)
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
    for i = 1, 100 do
        local hue = math.random(40, 220)
        table.insert(stars, {
            x = math.random(0, love.graphics.getWidth() + STAR_WARP_LINE_LENGTH * 2),
            y = math.random(0, love.graphics.getHeight() + STAR_WARP_LINE_LENGTH * 2),
            r = 1 + math.random() * 3,
            color = { hue, hue, hue }
        })
    end
    return stars
end

function draw_stars(stars, camera)
    for i, star in ipairs(stars) do
        love.graphics.setColor(star.color)
        local x = ((star.x - (camera.x / (-star.r + 5))) % (love.graphics.getWidth() + STAR_WARP_LINE_LENGTH * 2)) - STAR_WARP_LINE_LENGTH
        local y = ((star.y - (camera.y / (-star.r + 5))) % (love.graphics.getHeight() + STAR_WARP_LINE_LENGTH * 2)) - STAR_WARP_LINE_LENGTH
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
        love.graphics.circle('fill', bullet.physics.x, bullet.physics.y, 10)
    end
end

greek = {'alpha', 'beta', 'gamma', 'delta', 'epsilon', 'zeta', 'eta', 'theta', 'iota', 'kappa', 'lambda', 'mu', 'nu', 'xi', 'omicron', 'pi', 'rho', 'sigma', 'tau', 'upsilon', 'phi', 'chi', 'psi', 'omega'}

function draw_nav(objects)
    local size = math.min(love.graphics.getWidth(), love.graphics.getHeight())
    local cell_size = size / 24
    love.graphics.setColor(aly.colors.darkseagreen)
    love.graphics.setLineWidth(1)
    for x = 0, 23 do
        for y = 0, 23 do
            love.graphics.line(x * cell_size, y * cell_size, (x + 1) * cell_size, y * cell_size)
            love.graphics.line(x * cell_size, y * cell_size, x * cell_size, (y + 1) * cell_size)
            if x == 23 then
                love.graphics.print(greek[y+1], size + 10, 5 + y * cell_size)
            end
        end
    end
    love.graphics.line(size, 0, size, size)
    love.graphics.line(0, size, size,   size)

    local has_player = function() end
    for k, ship in ipairs(objects) do
        local x = size / 2 + ship.physics.x / 500
        local y = size / 2 + ship.physics.y / 500
        if ship == player then
            has_player = function()
                local x2, y2 = aly.move(x, y, player.physics.angle, 20 + player.warp.charge * 3000)
                love.graphics.setColor(aly.colors.darkseagreen)
                love.graphics.circle('fill', x, y, 3)
                love.graphics.setColor(aly.colors.white)
                love.graphics.line(x, y, x2, y2)
            end
        else
            love.graphics.setColor(aly.colors.blue)
            love.graphics.circle('fill', x, y, 3)
        end
    end

    has_player()
end
