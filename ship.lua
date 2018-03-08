function new_ship(x, y, draw_func)
    return {
        x = x, y = y,
        dx = 0, dy = 0,
        angle = math.random() * math.pi * 2,
        input = {},
        warp_charge = 0,
        warp_speed = 0,
        fire_delay = 0,
        stun_delay = 0,
        draw_func = draw_func
    }
end

function ship_process_input_movement(dt, ship)
    if ship.warp_charge == 1.0 then
        if ship.input.left then
            ship.angle = ship.angle - (WARP_ROTATION * dt)
        elseif ship.input.right then
            ship.angle = ship.angle + (WARP_ROTATION * dt)
        end
    elseif ship.warp_charge == 0 then
        if ship.input.left then
            ship.angle = ship.angle - (ROTATION * dt)
        elseif ship.input.right then
            ship.angle = ship.angle + (ROTATION * dt)
        end
    end

    if ship.warp_charge == 0 then
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
        if ship.warp_charge == 0.0 and ship.input.fire then
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
    if ship.input.warp then
        ship.warp_charge = aly.step(ship.warp_charge, 1.0, (1/2 * dt))
    else
        ship.warp_charge = aly.step(ship.warp_charge, 0, (3 * dt))
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
    if ship.warp_charge == 1.0 then
        ship.warp_speed = aly.step(
            ship.warp_speed,
            WARP_SPEED,
            WARP_SPEED * 0.8 * dt
        )
        ship.dx, ship.dy = aly.move(0, 0, ship.angle, ship.warp_speed * dt)
    else
        if ship.warp_speed > 0.1 then
            ship.dx, ship.dy = aly.move(0, 0, ship.angle, 100 * dt)
            ship.warp_speed = aly.step(ship.warp_speed, 0, WARP_SPEED * 6 * dt)
        end
        ship.dx = ship.dx - (ship.dx * DRAG * dt)
        ship.dy = ship.dy - (ship.dy * DRAG * dt)
    end

    ship.dx, ship.dy = limit_vector_distance(ship.dx, ship.dy, MAX_SPEED)

    ship.x = ship.x + ship.dx
    ship.y = ship.y + ship.dy
end

function update_ship(dt, ship)
    ship_physics(dt, ship)
    ship_process_input(dt, ship)
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

