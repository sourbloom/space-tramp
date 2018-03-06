function ship_speed(s)
    return aly.dist(0, 0, s.dx, s.dy)
end

function ship_angle_between(s1, s2)
    return aly.angle(s1.x, s1.y, s2.x, s2.y)
end

function ship_distance(s1, s2)
    return aly.dist(s1.x, s1.y, s2.x, s2.y)
end

function follow_behavior(me, target)
    local input = {}
    local a = ship_angle_between(me, target)

    if me.angle > ship_angle_between(me, target) then
        input.left = true
    else
        input.right = true
    end

    if ship_distance(me, target) > 200 and ship_speed(me) < 20 then
        input.forward = true
    end

    if target.input.warp then
       input.warp = true 
    end

    return input
end
