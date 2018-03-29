local aly = require('util.aly')
local turtle = require('util.turtle')
local palette = require('palette')
local misc = require('util.misc')

local graphics = {}

function graphics.get_window_size()
    return math.min(love.graphics.getWidth(), love.graphics.getHeight())
end

function graphics.get_cam_zoom()
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    local z

    if w > h then
        z = w / h
    elseif w < h then
        z = h / w
    else
        z = 1
    end

    z = math.max(z, 0.5)

    return z
end

function graphics.make_stars()
    local stars = {}
    for i = 1, 100 do
        local hue = math.random(40, 220)
        table.insert(stars, {
            x = math.random(0, 999999),
            y = math.random(0, 999999),
            r = 1 + math.random() * 3,
            color = { hue, hue, hue }
        })
    end
    return stars
end

function graphics.draw_stars(stars, camera)
    for i, star in ipairs(stars) do
        love.graphics.setColor(star.color)
        local x = ((star.x - (camera.x * camera.zoom / (-star.r + 5))) % (love.graphics.getWidth() + STAR_WARP_LINE_LENGTH * 2)) - STAR_WARP_LINE_LENGTH
        local y = ((star.y - (camera.y * camera.zoom / (-star.r + 5))) % (love.graphics.getHeight() + STAR_WARP_LINE_LENGTH * 2)) - STAR_WARP_LINE_LENGTH
        if player.warp.speed > 0.01 then
            local pspeed = aly.dist(0, 0, player.physics.dx, player.physics.dy)
            local x2, y2 = aly.move(
                x, y,
                player.physics.angle + math.pi,
                STAR_WARP_LINE_LENGTH * (player.warp.speed / WARP_SPEED)
            )
            love.graphics.setLineWidth(star.r)
            love.graphics.line(x, y, x2, y2)
        else
            love.graphics.circle('fill', x, y, star.r)
        end
    end
end

function graphics.draw_bullet(bullet)
    if not bullet.dead then
        love.graphics.setColor(aly.colors.red)
        love.graphics.circle('fill', bullet.physics.x, bullet.physics.y, 10)
    end
end

greek = {'alpha', 'beta', 'gamma', 'delta', 'epsilon', 'zeta', 'eta', 'theta', 'iota', 'kappa', 'lambda', 'mu', 'nu', 'xi', 'omicron', 'pi', 'rho', 'sigma', 'tau', 'upsilon', 'phi', 'chi', 'psi', 'omega'}

function graphics.nav_draw_dot(x, y, color, radius)
    love.graphics.setLineWidth(2)
    love.graphics.setColor(color or aly.colors.blue)
    love.graphics.circle((radius or 3) < 4 and 'fill' or 'line', x, y, radius or 3)
end

function graphics.draw_nav(objects)
    local size = math.min(love.graphics.getWidth(), love.graphics.getHeight())
    local cell_size = size / 10
    love.graphics.setColor(aly.colors.darkseagreen)
    love.graphics.setLineWidth(1)
    for x = 0, 9 do
        for y = 0, 9 do
            love.graphics.line(x * cell_size, y * cell_size, (x + 1) * cell_size, y * cell_size)
            love.graphics.line(x * cell_size, y * cell_size, x * cell_size, (y + 1) * cell_size)
            if x == 9 then
                love.graphics.print(greek[y+1], size + 10, 5 + y * cell_size)
            end
        end
    end
    love.graphics.line(size, 0, size, size)
    love.graphics.line(0, size, size, size)

    local x, y
    for k, object in ipairs(objects) do
        x = size / 2 + object.physics.x / 500
        y = size / 2 + object.physics.y / 500

        if object == player then
            local x2, y2 = aly.move(
                x,
                y,
                player.physics.angle,
                20 + player.warp.charge * 3000
            )
            graphics.nav_draw_dot(x, y)
            love.graphics.setColor(aly.colors.white)
            love.graphics.setLineWidth(1)
            love.graphics.line(x, y, x2, y2)
        elseif aly.contains_value(object.physics.collision, 'network') then
            graphics.nav_draw_dot(x, y, palette.warp, 15)
            for _, node in ipairs(object.neighbors) do
                local x2 = size / 2 + node.physics.x / 500
                local y2 = size / 2 + node.physics.y / 500
                love.graphics.setLineWidth(3)
                love.graphics.setColor(palette.warp)
                love.graphics.line(x, y, x2, y2)
            end
        else
            graphics.nav_draw_dot(x, y)
        end
    end
end

return graphics
