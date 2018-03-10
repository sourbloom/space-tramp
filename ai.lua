function ship_speed(s)
    return aly.dist(0, 0, s.physics.dx, s.physics.dy)
end

function ship_angle_between(s1, s2)
    return aly.angle(s1.physics.x, s1.physics.y, s2.physics.x, s2.physics.y)
end

function ship_distance(s1, s2)
    return aly.dist(s1.physics.x, s1.physics.y, s2.physics.x, s2.physics.y)
end

function gen_follow_behavior(target)
    return function(me)
        local input = {}

        if target.input.warp then
           input.warp = true
           me.physics.angle = target.physics.angle
        else
            local a = ship_angle_between(me, target)
            local near = ship_distance(me, target) < 200

            if me.physics.angle > ship_angle_between(me, target) then
                input.left = true
            else
                input.right = true
            end

            if not near and ship_speed(me) < 20 then
                input.forward = true
            end
        end

        return input
    end
end
