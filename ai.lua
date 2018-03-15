local aly = require('util.aly')

local ai = {}

function ai.ship_speed(s)
    return aly.dist(0, 0, s.physics.dx, s.physics.dy)
end

function ai.ship_angle_between(s1, s2)
    return aly.angle(s1.physics.x, s1.physics.y, s2.physics.x, s2.physics.y)
end

function ai.ship_distance(s1, s2)
    return aly.dist(s1.physics.x, s1.physics.y, s2.physics.x, s2.physics.y)
end

function ai.gen_follow_behavior(target)
    return function(me)
        local input = {}

        input.warp = love.keyboard.isDown('e')

        -- if target.input.warp then
           -- input.warp = true
           -- me.physics.angle = target.physics.angle
        -- else
            local a = ai.ship_angle_between(me, target)
            local near = ai.ship_distance(me, target) < 200

            if me.physics.angle > ai.ship_angle_between(me, target) then
                input.left = true
            else
                input.right = true
            end

            if not near and ai.ship_speed(me) < 20 then
                input.forward = true
            end
        -- end

        return input
    end
end

return ai
