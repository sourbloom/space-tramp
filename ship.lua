function new_ship(x, y, behavior, update, draw)
    return {
        behavior = behavior,
        update = update,
        draw = draw,

        physics = {
            x = x,
            y = y,
            angle = math.random() * math.pi * 2,
            dx = math.random(-3, 3),
            dy = math.random(-3, 3),
            size = 26,
            collision = {
                'solid',
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
        input = {},
    }
end


function ship_process_input_movement(dt, ship)
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

function ship_process_input_weapon(dt, ship)
    if ship.weapon.delay > 0 then
        ship.weapon.delay = ship.weapon.delay - 1 * dt
    else
        if ship.weapon.energy > 0.15 and ship.warp.charge == 0.0 and ship.input.fire then
            ship.weapon.energy = ship.weapon.energy - 0.15
            ship.weapon.delay = 0.5
            local bullet = {
                x = ship.physics.x,
                y = ship.physics.y,
                owner = ship,
                life = 1,
                dead = false
            }
            bullet.dx, bullet.dy = aly.move(ship.physics.dx, ship.physics.dy, ship.physics.angle, 15)
            table.insert(bullets, bullet)
        end
    end
end

function ship_process_input_warp(dt, ship)
    if ship.input.warp and ship.warp.fuel > 0.0 then
        ship.warp.charge = aly.step(ship.warp.charge, 1.0, (1/2 * dt))
    else
        ship.warp.charge = aly.step(ship.warp.charge, 0, (3 * dt))
    end
end

function ship_process_input(dt, ship)
    ship_process_input_movement(dt, ship)
    ship_process_input_warp(dt, ship)
    ship_process_input_weapon(dt, ship)
end

function limit_vector_distance(dx, dy, limit)
    if aly.dist(0, 0, dx, dy) > limit then
        dx, dy = aly.move(0, 0, aly.angle(0, 0, dx, dy), limit)
    end
    return dx, dy
end

function ship_physics(dt, ship)
    if ship.warp.charge == 1.0 then
        ship.warp.speed = aly.step(
            ship.warp.speed,
            WARP_SPEED,
            WARP_SPEED * 0.8 * dt
        )
        ship.warp.fuel = aly.step(ship.warp.fuel, 0.0, 1/20*dt)
        ship.physics.dx, ship.physics.dy = aly.move(0, 0, ship.physics.angle, ship.warp.speed * dt)
    else
        if ship.warp.speed > 0.1 then
            ship.physics.dx, ship.physics.dy = aly.move(0, 0, ship.physics.angle, 100 * dt)
            ship.warp.speed = aly.step(ship.warp.speed, 0, WARP_SPEED * 6 * dt)
        end
        ship.physics.dx = ship.physics.dx - (ship.physics.dx * DRAG * dt)
        ship.physics.dy = ship.physics.dy - (ship.physics.dy * DRAG * dt)
        ship.physics.dx, ship.physics.dy = limit_vector_distance(ship.physics.dx, ship.physics.dy, MAX_SPEED)
    end
    ship.weapon.energy = aly.step(ship.weapon.energy, 1.0, 1/15*dt)

    ship.physics.x = ship.physics.x + ship.physics.dx
    ship.physics.y = ship.physics.y + ship.physics.dy
end

function update_ship(dt, ship)
    ship.input = ship:behavior()
    ship_process_input(dt, ship)
    ship_physics(dt, ship)
end

function not_dead(t)
    return not t.dead
end

function update_bullet(dt, bullet)
    if bullet.life > 0 then
        bullet.life = bullet.life - 1 * dt
        bullet.x = bullet.x + bullet.dx
        bullet.y = bullet.y + bullet.dy
    else
        bullet.dead = true
    end
end

