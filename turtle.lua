require 'aly'

turtle = {}

function turtle:start(x, y, angle)
    self.x, self.y, self.angle = x, y, angle
    self.last_x, self.last_y = 0, 0    
    self.pen = true
    self.mirror = false
    self._original_angle = angle
    love.graphics.setColor(aly.colors.white)
    love.graphics.setLineWidth(1)
end

function turtle:mirror()
    self.mirror = true
end

function turtle:unmirror()
    self.mirror = false
end

function turtle:_I_moved()
    if self.pen then
        love.graphics.line(
            self.last_x, self.last_y,
            self.x, self.y
        )
        -- if self.mirror then
        --     love.graphics.line(
        --     -self.last_x, self.last_y,
        --     -self.x, self.y
        -- )
        -- end
    end
end

function turtle:forward(amt)
    self.last_x, self.last_y = self.x, self.y
    self.x, self.y = aly.move(self.x, self.y, self.angle, amt)
    self:_I_moved()
end

function turtle:left(amt)
    self.angle = self.angle - amt
end

function turtle:right(amt)
    self.angle = self.angle + amt
end

function turtle:strife_right(amt)
    turtle:right(math.pi / 4)
    turtle:forward(amt)
    turtle:left(math.pi / 4)
end

function turtle:strife_left(amt)
    turtle:left(math.pi / 4)
    turtle:forward(amt)
    turtle:right(math.pi / 4)
end

function turtle:set_angle(a)
    self.angle = self._original_angle + a
end

function turtle:back(amt)
    self.x, self.y = aly.move(self.x, self.y, self.angle + math.pi, amt)
    self:_I_moved()
end

function turtle:circle(r)
    love.graphics.circle('fill', math.floor(self.x), math.floor(self.y), r)
end

function turtle:pen_down()
    self.pen = true
end

function turtle:pen_up()
    self.pen = false
end

function turtle:pen_color(c)
    love.graphics.setColor(c)
end

function turtle:pen_width(w)
    love.graphics.setLineWidth(w)
end

function turtle:toggle_pen()
    self.pen = not self.pen
end
