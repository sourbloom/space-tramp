local aly = require 'aly'

local collision = {}

local rules = {}

function collision.add_rule(tags1, tags2, func)
    table.insert(rules, {
        tags1 = tags1,
        tags2 = tags2,
        func = func
    })
end

function collision.objects_touching(object1, object2)
    local dist = aly.dist(
        object1.physics.x, object1.physics.y,
        object2.physics.x, object2.physics.y
    )
    return dist <= object1.physics.size + object2.physics.size
end

function object_matches_tags(object, tags)
    for _, tag in ipairs(tags) do
        if not aly.contains_value(object.physics.collision, tag) then
            return false
        end
    end
    return true
end

-- print(object_matches_tags({physics = { collision = {'ship', 'solid'} }}, {'ship', 'solid'}))

function collision.objects_match_tags(object1, object2, tags1, tags2)
    return (
        object_matches_tags(object1, tags1) and
        object_matches_tags(object2, tags2)
    ) or (
        object_matches_tags(object1, tags2) and
        object_matches_tags(object2, tags1)
    )
end

function collision.check(objects)
    for _, pairing in ipairs(aly.all_pairs(objects)) do
        local object1, object2 = unpack(pairing)
        for _, rule in ipairs(rules) do
            if collision.objects_match_tags(object1, object2, rule.tags1, rule.tags2) and
               collision.objects_touching(object1, object2) then
                rule.func(object1, object2)
            end
        end
    end
end

collision.add_rule({'ship'}, {'ship'}, function(ship1, ship2)
    local angle = aly.angle(
        ship1.physics.x, ship1.physics.y,
        ship2.physics.x, ship2.physics.y
    )
    local ship1_speed = aly.dist(0, 0, ship1.physics.dx, ship1.physics.dy)
    local ship2_speed = aly.dist(0, 0, ship2.physics.dx, ship2.physics.dy)
    local avg_speed = (ship1_speed + ship2_speed) / 2
    ship1.physics.dx, ship1.physics.dy = aly.move(0, 0, angle + math.pi, avg_speed)
    ship2.physics.dx, ship2.physics.dy = aly.move(0, 0, angle, avg_speed)
end)

collision.add_rule({'ship'}, {'bullet'}, function(ship, bullet)
    if bullet.owner == ship then return end

    local angle = aly.angle(
        ship.physics.x, ship.physics.y,
        bullet.physics.x, bullet.physics.y
    )
    ship.physics.dx, ship.physics.dy = aly.move(0, 0, angle+math.pi, 15)
    bullet.dead = true
end)

return collision
