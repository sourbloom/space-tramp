local aly = require('util.aly')
local turtle = require('util.turtle')
local palette = require('palette')
local misc = require('util.misc')

local spaceship = {}

function spaceship.new(x, y, behavior, draw)
    return {
        physics = {
            x = x,
            y = y,
            angle = math.random() * math.pi * 2,
            dx = math.random(-3, 3),
            dy = math.random(-3, 3),
            size = 26,
            collision = {
                'ship'
            }
        },
        warp = {
            charge = 0,
            speed = 0,
            fuel = 0.91,
        },
        weapon = {
            delay = 0.0,
            energy = 1.0
        },
        shields = {
            charge = 1.0
        },

        behavior = behavior,
        update = spaceship.update_ship,
        draw = spaceship.gen_ship_draw(draw),

        input = {},
    }
end

function spaceship.gen_ship_draw(draw_func)
    return function(s)
        draw_func(s)
        spaceship.draw_warp_meter1(s)
    end
end

function spaceship.ship_process_input_movement(dt, s)
    if s.warp.charge == 1.0 then
        if s.input.left then
            s.physics.angle = s.physics.angle - (WARP_ROTATION * dt)
        elseif s.input.right then
            s.physics.angle = s.physics.angle + (WARP_ROTATION * dt)
        end
    elseif s.warp.charge == 0 then
        if s.input.left then
            s.physics.angle = s.physics.angle - (ROTATION * dt)
        elseif s.input.right then
            s.physics.angle = s.physics.angle + (ROTATION * dt)
        end
    end

    if s.warp.charge == 0 then
        if s.input.forward then
            local dx, dy = aly.move(0, 0, s.physics.angle, ACCEL)
            s.physics.dx = s.physics.dx + dx * dt
            s.physics.dy = s.physics.dy + dy * dt
        elseif s.input.reverse then
            local dx, dy = aly.move(0, 0, s.physics.angle + math.pi, ACCEL)
            s.physics.dx = s.physics.dx + dx * dt
            s.physics.dy = s.physics.dy + dy * dt
        end
    end
end

function spaceship.ship_process_input_weapon(dt, s)
    if s.weapon.delay > 0 then
        s.weapon.delay = s.weapon.delay - 1 * dt
    else
        if s.weapon.energy > 0.15 and s.warp.charge == 0.0 and s.input.fire then
            s.weapon.energy = s.weapon.energy - 0.15
            s.weapon.delay = 0.5
            local bullet = {
                physics = {
                    x = s.physics.x,
                    y = s.physics.y,
                    size = 5,
                    collision = {'bullet'}
                },
                owner = s,
                life = 1,
                dead = false,
                update = update_bullet,
                draw = draw_bullet
            }
            bullet.physics.dx, bullet.physics.dy = aly.move(
                s.physics.dx,
                s.physics.dy,
                s.physics.angle,
                15
            )
            table.insert(objects, bullet)
        end
    end
end

function spaceship.ship_process_input_warp(dt, s)
    if s.input.warp and s.warp.fuel > 0.0 then
        s.warp.charge = aly.step(s.warp.charge, 1.0, (1/2 * dt))
    else
        s.warp.charge = aly.step(s.warp.charge, 0, (3 * dt))
    end
end

function spaceship.ship_process_input(dt, s)
    spaceship.ship_process_input_movement(dt, s)
    spaceship.ship_process_input_warp(dt, s)
    spaceship.ship_process_input_weapon(dt, s)
end

function spaceship.limit_vector_distance(dx, dy, limit)
    if aly.dist(0, 0, dx, dy) > limit then
        dx, dy = aly.move(0, 0, aly.angle(0, 0, dx, dy), limit)
    end
    return dx, dy
end

function spaceship.ship_physics(dt, s)
    if s.warp.charge == 1.0 then
        s.warp.speed = aly.step(
            s.warp.speed,
            WARP_SPEED,
            WARP_SPEED * 2 * dt
        )
        -- s.warp.fuel = aly.step(s.warp.fuel, 0.0, 1/50*dt)
        s.physics.dx, s.physics.dy = aly.move(0, 0, s.physics.angle, s.warp.speed * dt)
    else
        if s.warp.speed > 0.1 then
            s.physics.dx, s.physics.dy = aly.move(0, 0, s.physics.angle, 100 * dt)
            s.warp.speed = aly.step(s.warp.speed, 0, WARP_SPEED * 6 * dt)
        end
        s.physics.dx = s.physics.dx - (s.physics.dx * DRAG * dt)
        s.physics.dy = s.physics.dy - (s.physics.dy * DRAG * dt)
        s.physics.dx, s.physics.dy = spaceship.limit_vector_distance(s.physics.dx, s.physics.dy, MAX_SPEED)
    end
    s.weapon.energy = aly.step(s.weapon.energy, 1.0, 1/15*dt)

    s.physics.x = s.physics.x + s.physics.dx
    s.physics.y = s.physics.y + s.physics.dy

    s.physics.collision.solid = s.warp.charge
end

function spaceship.update_ship(s, dt)
    s.input = s:behavior()
    spaceship.ship_process_input(dt, s)
    spaceship.ship_physics(dt, s)
end

function update_bullet(bullet, dt)
    if bullet.life > 0 then
        bullet.life = bullet.life - 1 * dt
        bullet.physics.x = bullet.physics.x + bullet.physics.dx
        bullet.physics.y = bullet.physics.y + bullet.physics.dy
    else
        bullet.dead = true
    end
end


function spaceship.draw_spinny(s)
    local t = turtle.new(s.physics.x, s.physics.y, s.physics.angle)
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

function spaceship.draw_enterprise(s, color, head_radius, body_length, engine_length, engine_dist, body_thickness)
    local t = turtle.new(s.physics.x, s.physics.y, s.physics.angle)
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

function spaceship.normal_enterprise(s)
    local color = aly.colors.lightslategray
    local head_radius = 14
    local body_length = 25
    local engine_length = 16
    local engine_dist = 26
    local body_thickness = 6
    spaceship.draw_enterprise(
        s,
        color,
        head_radius,
        body_length,
        engine_length,
        engine_dist,
        body_thickness
    )
end
function spaceship.gen_draw_random_enterprise()
    local color = aly.copy(aly.colors.lightslategray)
    color[1] = misc.clamp_color(color[1] + math.random(-50, 50))
    color[2] = misc.clamp_color(color[2] + math.random(-50, 50))
    color[3] = misc.clamp_color(color[3] + math.random(-50, 50))
    local head_radius = 14 + math.random(0, 8)
    local body_length = 25 + math.random(-2, 10)
    local engine_length = 16 + math.random(-5, 5)
    local engine_dist = 26 + math.random(-5, 5)
    local body_thickness = 6 + math.random(-4, 4)
    return function(s)
        spaceship.draw_enterprise(
            s,
            color,
            head_radius,
            body_length,
            engine_length,
            engine_dist,
            body_thickness
        )
    end
end

function spaceship.draw_fancy(s)
    local t = turtle.new(s.physics.x, s.physics.y, s.physics.angle)
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

function spaceship.draw_triangle(s)
    local t = turtle.new(s.physics.x, s.physics.y, s.physics.angle)
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

function spaceship.draw_test_ship(s)
    local t = turtle.new(s.physics.x, s.physics.y, s.physics.angle)
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

function spaceship.draw_warp_meter1(s)
    if s.warp.charge > 0 then
        love.graphics.setColor(palette.warp)
        love.graphics.setLineWidth(2 + 2 * s.warp.charge)
        love.graphics.arc(
            'line',
            'open',
            math.floor(s.physics.x), math.floor(s.physics.y),
            60,
            s.physics.angle + math.pi,
            s.physics.angle + math.pi + math.pi * s.warp.charge
        )
        love.graphics.arc(
            'line',
            'open',
            math.floor(s.physics.x), math.floor(s.physics.y),
            60,
            s.physics.angle + math.pi,
            s.physics.angle + math.pi - math.pi * s.warp.charge
        )
    end
end

function spaceship.draw_warp_meter2(s)
    if s.warp.charge > 0 and s.warp.charge < 1.0 then
        love.graphics.setColor(palette.warp)
        love.graphics.setLineWidth(10)
        love.graphics.arc(
            'line',
            'open',
            math.floor(s.physics.x), math.floor(s.physics.y),
            60,
            s.physics.angle,
            s.physics.angle + math.pi * 2 * s.warp.charge
        )
    end
end

return spaceship
