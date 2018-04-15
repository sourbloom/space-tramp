-- aly.lua
-- This is definitely and old version but oh well, update this when you find a better copy

local aly = {}

-------------------------------------------------------------------------------
-- Utilities
-------------------------------------------------------------------------------

-- oop

function aly.class(inherit)
    local class = {}

    setmetatable(class, {
        __index = inherit,
        __call  = function(class, ...)
            local obj = {}

            setmetatable(obj, {
                __index = class
            })

            obj.class = class
            if obj.load then obj:load(...) end

            return obj
        end
    })

    class.inherit = inherit

    return class
end

function aly.is_instance(instance, class)
    local c = instance.class
    if c == class then return true end

    while c.inherit do
        c = c.inherit
        if c == class then return true end
    end

    return false
end

-- returns the parent class of an instance
-- I think "pure" oop would require a class instead of an instance but yolo
function aly.super(instance)
    return instance.class.inherit
end

-- lua functions

function aly.ternary(cond, t, f)
    if cond then return t else return f end
end

function aly.index(table, val)
    for k, v in pairs(table) do
        if v == val then return k end
    end
    return nil
end

function aly.remove_value(tab, val)
    local i = index(tab, val)
    if i then
        table.remove(tab, i)
    end
end

-- this is a shallow copy!
function aly.copy(t)
    local copy = {}

    for k, v in pairs(t) do
        copy[k] = v
    end

    return copy
end

-- merge t2 into t1.  Will overwrite things in t1!
function aly.merge(t1, t2)
    for k, v in pairs(t2) do t1[k] = v end return t1
end

function aly.contains_value(table, value)
    for k, v in pairs(table) do
        if v == value then return true end
    end
    return false
end

function aly.contains_key(table, key)
    for k, v in pairs(table) do
        if k == key then return true end
    end
    return false
end

-- busy wait for x seconds.
-- there's no good portable sleep function for lua :(
-- <http://lua-users.org/wiki/SleepFunction>
function aly.sleep(seconds)
    local base = os.clock()
    while os.clock() - base <= seconds do end
end

-- string functions

function aly.split(str, sep)
    local sep, fields = sep or ',', {}
    local pattern = string.format("([^%s]+)", sep)

    str:gsub(pattern, function(c) fields[#fields+1] = c end)

    return fields
end

-- math functions

function aly.clamp(value, min, max)
    -- aly.clamp(x, 5) == aly.clamp(x, -5, 5)
    if max == nil then
        max =  min
        min = -min
    end

    return math.min(math.max(value, min), max)
end

function aly.dist(x1, y1, x2, y2)
    return math.sqrt(math.pow(x1 - x2, 2) + math.pow(y1 - y2, 2))
end

function aly.angle(x1, y1, x2, y2)
    return math.atan2(y2 - y1, x2 - x1)
end

function aly.mirror_angle(a, xflip, yflip)
    if xflip then
        a = math.pi - a
    end

    if yflip then
        a = a + math.pi / 2
        a = math.pi - a
        a = a - math.pi / 2
    end

    return a
end

function aly.move(x, y, angle, amt)
    return x + math.cos(angle) * amt, y + math.sin(angle) * amt
end

function aly.choice(tab, last)
    local c = last
    while c == last do
        c = tab[math.random(1, #tab)]
    end
    return c
end

function aly.step(val, to, step_amt)
    local amount = math.min(math.abs(val - to), step_amt)
    if val > to then
        return val - amount
    else
        return val + amount
    end
end

function aly.percent(per, min, max)
    return per * (max - min) + min
end

-- aly.once_states = {}
-- function aly.once(index, on)
--     if aly.once_states[index] == nil then
--         aly.once_states[index] = false
--     end

--     if on then
--         if aly.once_states[index] == false then
--             aly.once_states[index] = true
--             return true
--         elseif aly.once_states[index] == true then
--             return false
--         end
--     else
--         aly.once_states[index] = false
--         return false
--     end
-- end

-- collision functions

function aly.rect_intersect(x1, y1, w1, h1, x2, y2, w2, h2)
    if x1 and y1 and w1 == nil and h1 == nil and x2 == nil and y2 == nil and w2 == nil and h2 == nil then
        local o1, o2 = x1, y1
        x1, y1, w1, h1 = o1.x, o1.y, o1.w, o1.h
        x2, y2, w2, h2 = o2.x, o2.y, o2.w, o2.h
    end

    local ax2, ay2 = x1 + w1, y1 + h1
    local bx2, by2 = x2 + w2, y2 + h2
    return x1 < bx2 and ax2 > x2 and y1 < by2 and ay2 > y2
end

function aly.point_in_rect(x1, y1, x2, y2, w2, h2)
    return x >= x2 and x < x2 + w2 and
           y >= y2 and y < y2 + h2
end

function aly.line_intersect(l1p1x, l1p1y, l1p2x, l1p2y, l2p1x, l2p1y, l2p2x, l2p2y)
    local a1, b1, a2, b2 = l1p2y - l1p1y, l1p1x - l1p2x, l2p2y - l2p1y, l2p1x - l2p2x
    local c1, c2 = a1 * l1p1x + b1 * l1p1y, a2 * l2p1x + b2 * l2p1y
    local det, x, y = a1 * b2 - a2 * b1

    return det ~= 0
end

function aly.circle_rect_intersect(x1, y1, r1, x2, y2, w2, h2)
    return aly.rect_intersect(
        x1 - r1, y1 - r1,
        r1 * 2,  r1 * 2,
        x2, y2,
        w2, h2
    )
end

-- color functions

-- adapted from: <http://mjijackson.com/2008/02/rgb-to-hsl-and-rgb-to-hsv-color-model-conversion-algorithms-in-javascript>
function aly.hsv_to_rgb(h, s, v)
    local r, g, b

    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)

    local switch = i % 6
    if     switch == 0 then r = v g = t b = p
    elseif switch == 1 then r = q g = v b = p
    elseif switch == 2 then r = p g = v b = t
    elseif switch == 3 then r = p g = q b = v
    elseif switch == 4 then r = t g = p b = v
    elseif switch == 5 then r = v g = p b = q
    end

    return math.floor(r * 255), math.floor(g * 255), math.floor(b * 255)
end

-- debuging functions

function aly.print_centered(text, x, y, a)
    local font = love.graphics.getFont()
    love.graphics.print(
        text,
        x - (font:getWidth(text) / 2),
        y - (font:getHeight() / 2),
        a
    )
end

function aly.raw_print(s) io.write(s) end

function aly.print_table(tab, indent)
    indent = indent or 1

    if indent == 1 then
        aly.raw_print('[' .. tostring(tab) .. ']\n')
    end

    aly.raw_print('{\n')

    for k, v in pairs(tab) do
        if type(v) == 'table' then
            for i = 1, indent do aly.raw_print('\t') end
            aly.raw_print(tostring(k) .. ' = ')
            aly.print_table(v, indent + 1)
        else
            for i = 1, indent do aly.raw_print('\t') end
            aly.raw_print(tostring(k) .. ' = ' .. tostring(v) .. '\n')
        end
    end

    for i = 1, indent - 1 do aly.raw_print('\t') end
    aly.raw_print('}\n')

    if indent == 1 then aly.raw_print('\n') end
end

aly.fps_font = nil
function aly.draw_fps()
    if not aly.fps_font then
        aly.fps_font = love.graphics.newFont(12)
    end
    love.graphics.setFont(aly.fps_font)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 4, 4)
    love.graphics.setColor(255, 255, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 3, 3)
end

-- sane love.run function

function aly.run()
    local fps = 60

    math.randomseed(os.time())
    math.random() math.random()

    love.graphics.clear()
    love.graphics.present()

    if love.load then love.load() end

    local dt = 0

    while true do
        if love.event then
            love.event.pump()
            for e, a, b, c, d in love.event.poll() do
                if e == 'quit' then
                    if not love.quit or not love.quit() then
                        if love.audio then
                            love.audio.stop()
                        end
                        return
                    end
                end
                love.handlers[e](a, b, c, d)
            end
        end

        if love.timer then
            love.timer.step()
            dt = love.timer.getDelta()
        end

        if love.update then love.update(dt) end

        if love.graphics then
            love.graphics.clear()
            if love.draw then love.draw() end
        end

        if love.timer then love.timer.sleep(1 / fps) end

        love.graphics.present()
    end
end

------------------------------------------------------------------------------
-- Game Objects
-------------------------------------------------------------------------------

aly.Camera = aly.class()

function aly.Camera:load()
    self.x = love.graphics.getWidth()  / 2
    self.y = love.graphics.getHeight() / 2
    self.zoom  = 1
    self.angle = 0
end

function aly.Camera:update(dt) end

function aly.Camera:world_coords(x, y)
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()

    local function rotate(phi, x, y)
        local c, s = math.cos(phi), math.sin(phi)
        return c * x - s * y, s * x + c * y
    end

    local function div(s, x, y)
        return x / s, y / s
    end

    x, y = rotate(-self.rot, div(self.zoom, x - w / 2, y - h / 2))
    return x + self.x, y + self.y
end

function aly.Camera:mouse_pos()
    return self:worldCoords(love.mouse.getPosition())
end

function aly.Camera:push()
    local cx = love.graphics.getWidth()  / (2 * self.zoom)
    local cy = love.graphics.getHeight() / (2 * self.zoom)

    love.graphics.push()
    love.graphics.scale(self.zoom)
    love.graphics.translate(math.floor(cx), math.floor(cy))
    love.graphics.rotate(self.angle)
    love.graphics.translate(math.floor(-self.x), math.floor(-self.y))
end

function aly.Camera:pop()
    love.graphics.pop()
end

-------------------------------------------------------------------------------
-- Testing
-------------------------------------------------------------------------------

function aly.test()
    aly.oop_test()
    print('all tests passed :)')
end

function aly.oop_test()
    A = aly.class()
    function A:load()
        self.var = 1
    end

    B = aly.class(A)
    function B:load()
        aly.super(self).load(self)
    end

    b = B()

    assert(b.var == 1, "inheritence via aly.super failed!") 
    assert(aly.is_instance(b, A), "aly.is_instance failed!")
end

-------------------------------------------------------------------------------
-- Colors
-------------------------------------------------------------------------------

function aly.color_mult(color, amt)
    amt = amt or 0.5
    return {color[1] * amt, color[2] * amt, color[3] * amt}
end

aly.colors = {
    aliceblue                      = { 0.94, 0.97, 1.00 },
    antiquewhite                   = { 0.98, 0.92, 0.84 },
    aqua                           = { 0.00, 1.00, 1.00 },
    aquamarine                     = { 0.50, 1.00, 0.83 },
    azure                          = { 0.94, 1.00, 1.00 },
    beige                          = { 0.96, 0.96, 0.86 },
    bisque                         = { 1.00, 0.89, 0.77 },
    black                          = { 0.00, 0.00, 0.00 },
    blanchedalmond                 = { 1.00, 0.92, 0.80 },
    blue                           = { 0.00, 0.00, 1.00 },
    blueviolet                     = { 0.54, 0.17, 0.89 },
    brown                          = { 0.65, 0.16, 0.16 },
    burlywood                      = { 0.87, 0.72, 0.53 },
    cadetblue                      = { 0.37, 0.62, 0.63 },
    chartreuse                     = { 0.50, 1.00, 0.00 },
    chocolate                      = { 0.82, 0.41, 0.12 },
    coral                          = { 1.00, 0.50, 0.31 },
    cornflowerblue                 = { 0.39, 0.58, 0.93 },
    cornsilk                       = { 1.00, 0.97, 0.86 },
    crimson                        = { 0.86, 0.08, 0.24 },
    cyan                           = { 0.00, 1.00, 1.00 },
    darkblue                       = { 0.00, 0.00, 0.55 },
    darkcyan                       = { 0.00, 0.55, 0.55 },
    darkgoldenrod                  = { 0.72, 0.53, 0.04 },
    darkgray                       = { 0.66, 0.66, 0.66 },
    darkgreen                      = { 0.00, 0.39, 0.00 },
    darkkhaki                      = { 0.74, 0.72, 0.42 },
    darkmagenta                    = { 0.55, 0.00, 0.55 },
    darkolivegreen                 = { 0.33, 0.42, 0.18 },
    darkorange                     = { 1.00, 0.55, 0.00 },
    darkorchid                     = { 0.60, 0.20, 0.80 },
    darkred                        = { 0.55, 0.00, 0.00 },
    darksalmon                     = { 0.91, 0.59, 0.48 },
    darkseagreen                   = { 0.56, 0.74, 0.56 },
    darkslateblue                  = { 0.28, 0.24, 0.55 },
    darkslategray                  = { 0.18, 0.31, 0.31 },
    darkturquoise                  = { 0.00, 0.81, 0.82 },
    darkviolet                     = { 0.58, 0.00, 0.83 },
    deeppink                       = { 1.00, 0.08, 0.58 },
    deepskyblue                    = { 0.00, 0.75, 1.00 },
    dimgray                        = { 0.41, 0.41, 0.41 },
    dodgerblue                     = { 0.12, 0.56, 1.00 },
    firebrick                      = { 0.70, 0.13, 0.13 },
    floralwhite                    = { 1.00, 0.98, 0.94 },
    forestgreen                    = { 0.13, 0.55, 0.13 },
    fuchsia                        = { 1.00, 0.00, 1.00 },
    gainsboro                      = { 0.86, 0.86, 0.86 },
    ghostwhite                     = { 0.97, 0.97, 1.00 },
    gold                           = { 1.00, 0.84, 0.00 },
    goldenrod                      = { 0.85, 0.65, 0.13 },
    gray                           = { 0.50, 0.50, 0.50 },
    green                          = { 0.00, 0.50, 0.00 },
    greenyellow                    = { 0.68, 1.00, 0.18 },
    honeydew                       = { 0.94, 1.00, 0.94 },
    hotpink                        = { 1.00, 0.41, 0.71 },
    indianred                      = { 0.80, 0.36, 0.36 },
    indigo                         = { 0.29, 0.00, 0.51 },
    ivory                          = { 1.00, 1.00, 0.94 },
    khaki                          = { 0.94, 0.90, 0.55 },
    lavender                       = { 0.90, 0.90, 0.98 },
    lavenderblush                  = { 1.00, 0.94, 0.96 },
    lawngreen                      = { 0.49, 0.99, 0.00 },
    lemonchiffon                   = { 1.00, 0.98, 0.80 },
    lightblue                      = { 0.68, 0.85, 0.90 },
    lightcoral                     = { 0.94, 0.50, 0.50 },
    lightcyan                      = { 0.88, 1.00, 1.00 },
    lightgoldenrodyellow           = { 0.98, 0.98, 0.82 },
    lightgray                      = { 0.83, 0.83, 0.83 },
    lightgreen                     = { 0.56, 0.93, 0.56 },
    lightpink                      = { 1.00, 0.71, 0.76 },
    lightsalmon                    = { 1.00, 0.63, 0.48 },
    lightseagreen                  = { 0.13, 0.70, 0.67 },
    lightskyblue                   = { 0.53, 0.81, 0.98 },
    lightslategray                 = { 0.47, 0.53, 0.60 },
    lightsteelblue                 = { 0.69, 0.77, 0.87 },
    lightyellow                    = { 1.00, 1.00, 0.88 },
    lime                           = { 0.00, 1.00, 0.00 },
    limegreen                      = { 0.20, 0.80, 0.20 },
    linen                          = { 0.98, 0.94, 0.90 },
    magenta                        = { 1.00, 0.00, 1.00 },
    maroon                         = { 0.50, 0.00, 0.00 },
    mediumaquamarine               = { 0.40, 0.80, 0.67 },
    mediumblue                     = { 0.00, 0.00, 0.80 },
    mediumorchid                   = { 0.73, 0.33, 0.83 },
    mediumpurple                   = { 0.58, 0.44, 0.85 },
    mediumseagreen                 = { 0.24, 0.70, 0.44 },
    mediumslateblue                = { 0.48, 0.41, 0.93 },
    mediumspringgreen              = { 0.00, 0.98, 0.60 },
    mediumturquoise                = { 0.28, 0.82, 0.80 },
    mediumvioletred                = { 0.78, 0.08, 0.52 },
    midnightblue                   = { 0.10, 0.10, 0.44 },
    mintcream                      = { 0.96, 1.00, 0.98 },
    mistyrose                      = { 1.00, 0.89, 0.88 },
    moccasin                       = { 1.00, 0.89, 0.71 },
    navajowhite                    = { 1.00, 0.87, 0.68 },
    navy                           = { 0.00, 0.00, 0.50 },
    oldlace                        = { 0.99, 0.96, 0.90 },
    olive                          = { 0.50, 0.50, 0.00 },
    olivedrab                      = { 0.41, 0.56, 0.14 },
    orange                         = { 1.00, 0.65, 0.00 },
    orangered                      = { 1.00, 0.27, 0.00 },
    orchid                         = { 0.85, 0.44, 0.84 },
    palegoldenrod                  = { 0.93, 0.91, 0.67 },
    palegreen                      = { 0.60, 0.98, 0.60 },
    paleturquoise                  = { 0.69, 0.93, 0.93 },
    palevioletred                  = { 0.85, 0.44, 0.58 },
    papayawhip                     = { 1.00, 0.94, 0.84 },
    peachpuff                      = { 1.00, 0.85, 0.73 },
    peru                           = { 0.80, 0.52, 0.25 },
    pink                           = { 1.00, 0.75, 0.80 },
    plum                           = { 0.87, 0.63, 0.87 },
    powderblue                     = { 0.69, 0.88, 0.90 },
    purple                         = { 0.50, 0.00, 0.50 },
    red                            = { 1.00, 0.00, 0.00 },
    rosybrown                      = { 0.74, 0.56, 0.56 },
    royalblue                      = { 0.25, 0.41, 0.88 },
    saddlebrown                    = { 0.55, 0.27, 0.07 },
    salmon                         = { 0.98, 0.50, 0.45 },
    sandybrown                     = { 0.96, 0.64, 0.38 },
    seagreen                       = { 0.18, 0.55, 0.34 },
    seashell                       = { 1.00, 0.96, 0.93 },
    sienna                         = { 0.63, 0.32, 0.18 },
    silver                         = { 0.75, 0.75, 0.75 },
    skyblue                        = { 0.53, 0.81, 0.92 },
    slateblue                      = { 0.42, 0.35, 0.80 },
    slategray                      = { 0.44, 0.50, 0.56 },
    snow                           = { 1.00, 0.98, 0.98 },
    springgreen                    = { 0.00, 1.00, 0.50 },
    steelblue                      = { 0.27, 0.51, 0.71 },
    tan                            = { 0.82, 0.71, 0.55 },
    teal                           = { 0.00, 0.50, 0.50 },
    thistle                        = { 0.85, 0.75, 0.85 },
    tomato                         = { 1.00, 0.39, 0.28 },
    turquoise                      = { 0.25, 0.88, 0.82 },
    violet                         = { 0.93, 0.51, 0.93 },
    wheat                          = { 0.96, 0.87, 0.70 },
    white                          = { 1.00, 1.00, 1.00 },
    whitesmoke                     = { 0.96, 0.96, 0.96 },
    yellow                         = { 1.00, 1.00, 0.00 },
    yellowgreen                    = { 0.60, 0.80, 0.20 },
}


-------------------------------------------------------------------------------
-- NEW STUFF
-------------------------------------------------------------------------------

function aly.compose(...)
    local funcs = {...}
    return function(a)
        local result = a
        for _, func in ipairs(funcs) do
            result = func(result)
        end
        return result
    end
end

--[[

ex

function add1(n) return n + 1 end
r = compose(add1, add1, add1)
print(r(5))
8

]]--

function aly.gen_call_all(...)
    local arg = {...}
    return function(...)
        for k, v in ipairs(arg) do
            v(...)
        end
    end
end

--[[

ex

function a(a, b)
    print(a, b)
end

b = aly.gen_call_all(a,a,a)
b(1, 2)

]]--

function aly.gen_output(func)
    local value = 0.0
    return function(amt, input)
        if amt then
            if input then
                value = value + amt
            else
                value = value - amt
            end
            value = math.min(1.0, math.max(0, value))
        end
        return func(value)
    end
end

--[[

ex

function identity(n)
    return n
end

function loger(n)
    return n * n
end

a = gen_output(identity)
print(a(0.5 * dt, true))

]]--

function aly.all_pairs(objects)
    local result = {}
    for i, object1 in ipairs(objects) do
        for j, object2 in ipairs(objects) do
            if i < j and object1 ~= object2 then
                table.insert(result, {object1, object2})
            end
        end
    end
    return result
end

return aly
