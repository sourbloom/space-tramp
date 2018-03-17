local aly = require('util.aly')

local network_node = {}

function network_node.new(options)
    return {
        physics = {
            x = options.x or math.random(-1000, 1000),
            y = options.y or math.random(-1000, 1000),
            collision = {
                'network'
            }
        },
        draw = network_node.draw,
        update = function() end,

        neighbors = {},
        attach = network_node.attach
    }
end

function network_node.attach(node, target)
    table.insert(node.neighbors, target)
    table.insert(target.neighbors, node)
end

function network_node.draw(node)
    love.graphics.setColor(aly.colors.blue)
    love.graphics.setLineWidth(5)
    love.graphics.circle('line', node.physics.x, node.physics.y, 300)
end

return network_node
