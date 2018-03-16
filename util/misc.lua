local aly = require('util.aly')

local misc = {}

function misc.clamp_color(color)
    return aly.clamp(color, 0, 255)
end

function misc.not_dead(t)
    return not t.dead
end

function misc.chain_funcs(func1, func2)
    return function(...)
        func1(...)
        func2(...)
    end
end

return misc
