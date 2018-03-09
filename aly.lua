-- aly.lua
-- This is definitely and old version but oh well, update this when you find a better copy

aly = {}

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

function aly.print_centered(text, x, y)
    local font = love.graphics.getFont()
    love.graphics.print(
        text,
        x - (font:getWidth(text) / 2),
        y - (font:getHeight() / 2)
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
    aliceblue            = {240, 248, 255},
    antiquewhite         = {250, 235, 215},
    aqua                 = {  0, 255, 255},
    aquamarine           = {127, 255, 212},
    azure                = {240, 255, 255},
    beige                = {245, 245, 220},
    bisque               = {255, 228, 196},
    black                = {  0,   0,   0},
    blanchedalmond       = {255, 235, 205},
    blue                 = {  0,   0, 255},
    blueviolet           = {138,  43, 226},
    brown                = {165,  42,  42},
    burlywood            = {222, 184, 135},
    cadetblue            = { 95, 158, 160},
    chartreuse           = {127, 255,   0},
    chocolate            = {210, 105,  30},
    coral                = {255, 127,  80},
    cornflowerblue       = {100, 149, 237},
    cornsilk             = {255, 248, 220},
    crimson              = {220,  20,  60},
    cyan                 = {  0, 255, 255},
    darkblue             = {  0,   0, 139},
    darkcyan             = {  0, 139, 139},
    darkgoldenrod        = {184, 134,  11},
    darkgray             = {169, 169, 169},
    darkgreen            = {  0, 100,   0},
    darkkhaki            = {189, 183, 107},
    darkmagenta          = {139,   0, 139},
    darkolivegreen       = { 85, 107,  47},
    darkorange           = {255, 140,   0},
    darkorchid           = {153,  50, 204},
    darkred              = {139,   0,   0},
    darksalmon           = {233, 150, 122},
    darkseagreen         = {143, 188, 143},
    darkslateblue        = { 72,  61, 139},
    darkslategray        = { 47,  79,  79},
    darkturquoise        = {  0, 206, 209},
    darkviolet           = {148,   0, 211},
    deeppink             = {255,  20, 147},
    deepskyblue          = {  0, 191, 255},
    dimgray              = {105, 105, 105},
    dodgerblue           = { 30, 144, 255},
    firebrick            = {178,  34,  34},
    floralwhite          = {255, 250, 240},
    forestgreen          = { 34, 139,  34},
    fuchsia              = {255,   0, 255},
    gainsboro            = {220, 220, 220},
    ghostwhite           = {248, 248, 255},
    gold                 = {255, 215,   0},
    goldenrod            = {218, 165,  32},
    gray                 = {128, 128, 128},
    green                = {  0, 128,   0},
    greenyellow          = {173, 255,  47},
    honeydew             = {240, 255, 240},
    hotpink              = {255, 105, 180},
    indianred            = {205,  92,  92},
    indigo               = { 75,   0, 130},
    ivory                = {255, 255, 240},
    khaki                = {240, 230, 140},
    lavender             = {230, 230, 250},
    lavenderblush        = {255, 240, 245},
    lawngreen            = {124, 252,   0},
    lemonchiffon         = {255, 250, 205},
    lightblue            = {173, 216, 230},
    lightcoral           = {240, 128, 128},
    lightcyan            = {224, 255, 255},
    lightgoldenrodyellow = {250, 250, 210},
    lightgray            = {211, 211, 211},
    lightgreen           = {144, 238, 144},
    lightpink            = {255, 182, 193},
    lightsalmon          = {255, 160, 122},
    lightseagreen        = { 32, 178, 170},
    lightskyblue         = {135, 206, 250},
    lightslategray       = {119, 136, 153},
    lightsteelblue       = {176, 196, 222},
    lightyellow          = {255, 255, 224},
    lime                 = {  0, 255,   0},
    limegreen            = { 50, 205,  50},
    linen                = {250, 240, 230},
    magenta              = {255,   0, 255},
    maroon               = {128,   0,   0},
    mediumaquamarine     = {102, 205, 170},
    mediumblue           = {  0,   0, 205},
    mediumorchid         = {186,  85, 211},
    mediumpurple         = {147, 112, 216},
    mediumseagreen       = { 60, 179, 113},
    mediumslateblue      = {123, 104, 238},
    mediumspringgreen    = {  0, 250, 154},
    mediumturquoise      = { 72, 209, 204},
    mediumvioletred      = {199,  21, 133},
    midnightblue         = { 25,  25, 112},
    mintcream            = {245, 255, 250},
    mistyrose            = {255, 228, 225},
    moccasin             = {255, 228, 181},
    navajowhite          = {255, 222, 173},
    navy                 = {  0,   0, 128},
    oldlace              = {253, 245, 230},
    olive                = {128, 128,   0},
    olivedrab            = {104, 142,  35},
    orange               = {255, 165,   0},
    orangered            = {255,  69,   0},
    orchid               = {218, 112, 214},
    palegoldenrod        = {238, 232, 170},
    palegreen            = {152, 251, 152},
    paleturquoise        = {175, 238, 238},
    palevioletred        = {216, 112, 147},
    papayawhip           = {255, 239, 213},
    peachpuff            = {255, 218, 185},
    peru                 = {205, 133,  63},
    pink                 = {255, 192, 203},
    plum                 = {221, 160, 221},
    powderblue           = {176, 224, 230},
    purple               = {128,   0, 128},
    red                  = {255,   0,   0},
    rosybrown            = {188, 143, 143},
    royalblue            = { 65, 105, 225},
    saddlebrown          = {139,  69,  19},
    salmon               = {250, 128, 114},
    sandybrown           = {244, 164,  96},
    seagreen             = { 46, 139,  87},
    seashell             = {255, 245, 238},
    sienna               = {160,  82,  45},
    silver               = {192, 192, 192},
    skyblue              = {135, 206, 235},
    slateblue            = {106,  90, 205},
    slategray            = {112, 128, 144},
    snow                 = {255, 250, 250},
    springgreen          = {  0, 255, 127},
    steelblue            = { 70, 130, 180},
    tan                  = {210, 180, 140},
    teal                 = {  0, 128, 128},
    thistle              = {216, 191, 216},
    tomato               = {255,  99,  71},
    turquoise            = { 64, 224, 208},
    violet               = {238, 130, 238},
    wheat                = {245, 222, 179},
    white                = {255, 255, 255},
    whitesmoke           = {245, 245, 245},
    yellow               = {255, 255,   0},
    yellowgreen          = {154, 205,  50}
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
