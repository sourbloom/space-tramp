function new_ship(x, y, draw_func)
    return {
        x = x, y = y,
        dx = 0, dy = 0,
        angle = math.random() * math.pi * 2,
        input = {},
        warp_charge = 0,
        draw_func = draw_func
    }
end

function move_ship_via_input(dt, ship)
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

    ship.dx = aly.clamp(ship.dx, 100)
    ship.dy = aly.clamp(ship.dy, 100)
end

function warp_engine_charge_via_input(dt, ship)
    if ship.input.warp then
        if ship.warp_charge < 1.0 then
            ship.warp_charge = ship.warp_charge + (1/4 * dt)
        else
            ship.warp_charge = 1.0
        end
    else
        if ship.warp_charge > 0 then
            ship.warp_charge = ship.warp_charge - (2 * dt)
        else
            ship.warp_charge = 0
        end
    end
end

function operate_ship(dt, ship)
    move_ship_via_input(dt, ship)
    warp_engine_charge_via_input(dt, ship)
end

function move_ship(dt, ship)
    if ship.warp_charge == 1.0 then
        ship.x, ship.y = aly.move(ship.x, ship.y, ship.angle, WARP_SPEED * dt)
        ship.dx, ship.dy = aly.move(0, 0, ship.angle, 5)
    else
        ship.x = ship.x + ship.dx
        ship.y = ship.y + ship.dy
        ship.dx = ship.dx - (ship.dx * DRAG * dt)
        ship.dy = ship.dy - (ship.dy * DRAG * dt)
    end
end
