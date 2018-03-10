function new_ship(x, y, behavior, draw_func)
    return {
        x = x, y = y,
        dx = math.random(-3, 3), dy = math.random(-3, 3),
        angle = math.random() * math.pi * 2,
        input = {},
        warp = {
            charge = 0,
            speed = 0,
            fuel = 0.91,
        },
        fire_delay = 0,
        stun_delay = 0,
        behavior = behavior or function() end,
        shields = 1.0,
        weapon_energy = 1.0,
        draw_func = draw_func,
    }
end

function ship_process_input_movement(dt, ship)
    if ship.warp.charge == 1.0 then
        if ship.input.left then
            ship.angle = ship.angle - (WARP_ROTATION * dt)
        elseif ship.input.right then
            ship.angle = ship.angle + (WARP_ROTATION * dt)
        end
    elseif ship.warp.charge == 0 then
        if ship.input.left then
            ship.angle = ship.angle - (ROTATION * dt)
        elseif ship.input.right then
            ship.angle = ship.angle + (ROTATION * dt)
        end
    end

    if ship.warp.charge == 0 then
        if ship.input.forward then
            local dx, dy = aly.move(0, 0, ship.angle, ACCEL)
            ship.dx = ship.dx + dx * dt
            ship.dy = ship.dy + dy * dt
        elseif ship.input.reverse then
            local dx, dy = aly.move(0, 0, ship.angle + math.pi, ACCEL)
            ship.dx = ship.dx + dx * dt
            ship.dy = ship.dy + dy * dt
        end
    end
end

function ship_process_input_weapons(dt, ship)
    if ship.fire_delay > 0 then
        ship.fire_delay = ship.fire_delay - 1 * dt
    else
        if ship.weapon_energy > 0.15 and ship.warp.charge == 0.0 and ship.input.fire then
            ship.weapon_energy = ship.weapon_energy - 0.15
            ship.fire_delay = 0.5
            local bullet = {
                x = ship.x,
                y = ship.y,
                owner = ship,
                life = 1,
                dead = false
            }
            bullet.dx, bullet.dy = aly.move(ship.dx, ship.dy, ship.angle, 15)
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
    ship_process_input_weapons(dt, ship)
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
        ship.dx, ship.dy = aly.move(0, 0, ship.angle, ship.warp.speed * dt)
    else
        if ship.warp.speed > 0.1 then
            ship.dx, ship.dy = aly.move(0, 0, ship.angle, 100 * dt)
            ship.warp.speed = aly.step(ship.warp.speed, 0, WARP_SPEED * 6 * dt)
        end
        ship.dx = ship.dx - (ship.dx * DRAG * dt)
        ship.dy = ship.dy - (ship.dy * DRAG * dt)
        ship.dx, ship.dy = limit_vector_distance(ship.dx, ship.dy, MAX_SPEED)
    end
    ship.weapon_energy = aly.step(ship.weapon_energy, 1.0, 1/15*dt)

    ship.x = ship.x + ship.dx
    ship.y = ship.y + ship.dy
end

function update_ship(dt, ship)
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

