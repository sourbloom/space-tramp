local aly = require('util.aly')
local turtle = require('util.turtle')
local graphics = require('graphics')
local palette = require('palette')
local misc = require('util.misc')

local spaceship = {}

function spaceship.new(options)
    return {
        physics = {
            x = options.x or math.random(-1000, 1000),
            y = options.y or math.random(-1000, 1000),
            angle = options.angle or math.random() * math.pi * 2,
            dx = options.dx or math.random(-3, 3),
            dy = options.dy or math.random(-3, 3),
            size = options.size or 26,
            collision = aly.merge({
                ship = true,
                solid = true
            }, options.collision or {})
        },

        warp = {
            charge = 0,
            speed = 0,
            fuel = options.warp_fuel or 0.91
        },

        weapon = {
            delay = 0.0,
            energy = 1.0
        },

        shields = {
            charge = options.shields or 1.0
        },

        communication = {
            on_message = function(ship, message) end
        },

        behavior = options.behavior or function() return {} end,

        update = options.update or spaceship.update_ship,

        draw = misc.chain_funcs(
            options.draw or spaceship.gen_draw_random_enterprise(),
            spaceship.draw_warp_meter2
        ),

        input = {},
    }
end

function spaceship.send_message(message)
end

function spaceship.gen_draw(draw_func)
    return function(ship)
        draw_func(ship)
        spaceship.draw_warp_meter2(ship)
    end
end



function spaceship.process_input_communication(dt, ship)
    if ship.input.hail then

    end
end

function spaceship.process_input_movement(dt, ship)
    if ship.warp.charge == 1.0 then
        if ship.input.left then
            ship.physics.angle = ship.physics.angle - (WARP_ROTATION * dt)
        elseif ship.input.right then
            ship.physics.angle = ship.physics.angle + (WARP_ROTATION * dt)
        end
    elseif ship.warp.charge == 0 then
        if ship.input.left then
            ship.physics.angle = ship.physics.angle - (ROTATION * dt)
        elseif ship.input.right then
            ship.physics.angle = ship.physics.angle + (ROTATION * dt)
        end
    end

    if ship.warp.charge == 0 then
        if ship.input.forward then
            local dx, dy = aly.move(0, 0, ship.physics.angle, ACCEL)
            ship.physics.dx = ship.physics.dx + dx * dt
            ship.physics.dy = ship.physics.dy + dy * dt
        elseif ship.input.reverse then
            local dx, dy = aly.move(0, 0, ship.physics.angle + math.pi, ACCEL)
            ship.physics.dx = ship.physics.dx + dx * dt
            ship.physics.dy = ship.physics.dy + dy * dt
        end
    end
end

function spaceship.process_input_weapon(dt, ship)
    if ship.weapon.delay > 0 then
        ship.weapon.delay = ship.weapon.delay - 1 * dt
    else
        if ship.weapon.energy > 0.15 and ship.warp.charge == 0.0 and ship.input.fire then
            ship.weapon.energy = ship.weapon.energy - 0.15
            ship.weapon.delay = 0.5
            local bullet = {
                physics = {
                    x = ship.physics.x,
                    y = ship.physics.y,
                    size = 5,
                    collision = {
                        bullet = true
                    }
                },
                owner = ship,
                life = 1,
                dead = false,
                update = update_bullet,
                draw = graphics.draw_bullet
            }
            bullet.physics.dx, bullet.physics.dy = aly.move(
                ship.physics.dx,
                ship.physics.dy,
                ship.physics.angle,
                15
            )
            table.insert(objects, bullet)
        end
    end
end

function spaceship.process_input_warp(dt, ship)
    if ship.input.warp and ship.warp.fuel > 0.0 then
        ship.warp.charge = aly.step(ship.warp.charge, 1.0, (1/2 * dt))
    else
        ship.warp.charge = aly.step(ship.warp.charge, 0, (3 * dt))
    end
end

function spaceship.process_input(dt, ship)
    spaceship.process_input_movement(dt, ship)
    spaceship.process_input_warp(dt, ship)
    spaceship.process_input_weapon(dt, ship)
end

function spaceship.limit_vector_distance(dx, dy, limit)
    if aly.dist(0, 0, dx, dy) > limit then
        dx, dy = aly.move(0, 0, aly.angle(0, 0, dx, dy), limit)
    end
    return dx, dy
end

function spaceship.physics(dt, ship)
    if ship.warp.charge == 1.0 then
        ship.warp.speed = aly.step(
            ship.warp.speed,
            WARP_SPEED,
            WARP_SPEED * 2 * dt
        )
        -- ship.warp.fuel = aly.step(ship.warp.fuel, 0.0, 1/50*dt)
        ship.physics.dx, ship.physics.dy = aly.move(0, 0, ship.physics.angle, ship.warp.speed * dt)
    else
        if ship.warp.speed > 0.1 then
            ship.physics.dx, ship.physics.dy = aly.move(0, 0, ship.physics.angle, 100 * dt)
            ship.warp.speed = aly.step(ship.warp.speed, 0, WARP_SPEED * 6 * dt)
        end
        ship.physics.dx = ship.physics.dx - (ship.physics.dx * DRAG * dt)
        ship.physics.dy = ship.physics.dy - (ship.physics.dy * DRAG * dt)
        ship.physics.dx, ship.physics.dy = spaceship.limit_vector_distance(ship.physics.dx, ship.physics.dy, MAX_SPEED)
    end
    ship.weapon.energy = aly.step(ship.weapon.energy, 1.0, 1/15*dt)

    ship.physics.x = ship.physics.x + ship.physics.dx
    ship.physics.y = ship.physics.y + ship.physics.dy

    ship.physics.collision.solid = ship.warp.charge ~= 1.0
end

function spaceship.update_ship(ship, dt)
    ship.input = ship:behavior()
    spaceship.process_input(dt, ship)
    spaceship.physics(dt, ship)
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

function spaceship.draw_spinny(ship)
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

function spaceship.draw_enterprise(ship, color, head_radius, body_length, engine_length, engine_dist, body_thickness)
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

function spaceship.normal_enterprise(ship)
    local color = aly.colors.lightslategray
    local head_radius = 14
    local body_length = 25
    local engine_length = 16
    local engine_dist = 26
    local body_thickness = 6
    spaceship.draw_enterprise(
        ship,
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
    return function(ship)
        spaceship.draw_enterprise(
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

function spaceship.draw_fancy(ship)
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

function spaceship.draw_triangle(ship)
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

function spaceship.draw_test_ship(ship)
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

function spaceship.draw_warp_meter1(ship)
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

function spaceship.draw_warp_meter2(ship)
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

return spaceship
