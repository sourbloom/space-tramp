require 'aly'

function new_single_turtle(x, y, angle)
    assert(x and y and angle, 'turtle not getting fed!!')

    local x, y, angle = x, y, angle
    local last_x, last_y = nil, nil
    local pen = true
    local pen_color = aly.colors.white
    local pen_width = 1
    local state_stack = {}

    local turtle = {}

    local function i_moved()
        if pen then
            -- print(last_x, last_y, x, y, pen_color)
            love.graphics.setColor(pen_color)
            love.graphics.setLineWidth(pen_width)
            love.graphics.line(last_x, last_y, x, y)
        end
    end

    turtle.forward = function(amt)
        last_x, last_y = x, y
        x, y = aly.move(x, y, angle, amt)
        i_moved()
    end

    turtle.back = function(amt)
        turtle.forward(-amt)
    end

    turtle.right = function(amt)
        angle = angle + amt
    end

    turtle.left = function(amt)
        angle = angle - amt
    end

    turtle.pen = function(val)
        pen = val
    end

    turtle.pen_width = function(width)
        pen_width = width
    end

    turtle.pen_color = function(color)
        pen_color = color
    end

    turtle.push = function()
        table.insert(state_stack, {x, y, angle, pen, color})
    end

    turtle.pop = function()
        assert(#state_stack > 0, 'extra pop on a turtle!!')
        x, y, angle, pen, color = unpack(table.remove(state_stack, #state_stack))
    end

    turtle.circle = function(r)
        if pen then
            love.graphics.setColor(pen_color)
            love.graphics.circle('fill', x, y, r)
        end
    end

    return turtle
end

function new_turtle(x, y, angle)
    local t1 = new_single_turtle(x, y, angle)
    local t2 = new_single_turtle(x, y, angle)

    local mirror = false
    local pen_state = true
    t1.pen(true)
    t2.pen(false)

    local turtles = {}

    turtles.forward = function(amt)
        t1.forward(amt)
        t2.forward(amt)
    end

    turtles.back = function(amt)
        t1.back(amt)
        t2.back(amt)
    end

    turtles.right = function(amt)
        t1.right(amt)
        t2.left(amt)
    end

    turtles.left = function(amt)
        t1.left(amt)
        t2.right(amt)
    end

    turtles.pen = function(val)
        pen_state = val
        t1.pen(val)
        if mirror then
            t2.pen(val)
        end
    end

    turtles.pen_width = function(width)
        t1.pen_width(width)
        t2.pen_width(width)
    end

    turtles.pen_color = function(color)
        t1.pen_color(color)
        t2.pen_color(color)
    end

    turtles.push = function()
        t1.push()
        t2.push()
    end

    turtles.pop = function()
        t1.pop()
        t2.pop()
    end

    turtles.circle = function(r)
        t1.circle(r)
        t2.circle(r)
    end

    turtles.mirror = function(val)
        mirror = val
        if mirror then
            t2.pen(pen_state)
        else
            t2.pen(false)
        end
    end

    return turtles
end

