-- space tramp!

-- util
require 'aly'
require 'turtle'
require 'functional'

-- game code
require 'ship'
require 'ai'
require 'controls'
require 'graphics'


function love.load()
    -- WINDOW_WIDTH, WINDOW_HEIGHT = 1280, 720
    WINDOW_WIDTH, WINDOW_HEIGHT = 1000, 1000
    MAX_SPEED = 10
    ACCEL = 10
    DRAG = 0.3
    ROTATION = math.pi * 3 / 2
    WARP_ROTATION = math.pi / 14
    WARP_SPEED = 5000
    STAR_WARP_LINE_LENGTH = 150

    camera = aly.Camera()
    camera.zoom = 0.5

    if love.system.getOS() == 'Android' or love.system.getOS() == 'iOS' then
        camera.zoom = 1
        WINDOW_WIDTH, WINDOW_HEIGHT = love.window.getDesktopDimensions()
    end

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)

    math.randomseed(os.time())

    ships = {}

    player = new_ship(0, 0, player_input, draw_triangle)
    table.insert(ships, player)

    for i = 1, 20 do
        table.insert(ships, new_ship(
            math.random(-1000, 1000),
            math.random(-1000, 1000),
            gen_follow_behavior(player),
            gen_draw_random_enterprise()
        ))
    end

    bullets = {}

    stars = make_stars()
end

function love.keypressed(key)
    if key == 'escape' or key == 'q' then
        love.event.push('quit')
    -- elseif key == 'f11' then
    --     love.window.setFullscreen(not love.window.getFullscreen(), 'desktop')
    end
end

function love.update(dt)
    -- player.input = keyboard_or_gamepad(player.input)

    for _, ship in ipairs(ships) do
        ship:behavior()
        update_ship(dt, ship)
    end

    for _, bullet in ipairs(bullets) do
        update_bullet(dt, bullet)
    end

    bullets = filter(not_dead, bullets)
    ships = filter(not_dead, ships)
end

function love.draw()
    draw_stars(stars, camera)

    camera.x = player.x
    camera.y = player.y
    -- camera.zoom = 0.5 - player.warp_charge * 0.2
    camera:push()

    for _, ship in ipairs(ships) do
        ship:draw_func()
        draw_warp_meter(ship)
    end

    for _, bullet in ipairs(bullets) do
        draw_bullet(bullet)
    end

    camera:pop()

    if player.input.nav then
        love.graphics.setColor(aly.colors.darkseagreen)
        love.graphics.setLineWidth(1)
        for x = 0, WINDOW_WIDTH / 100 do
            for y = 0, WINDOW_HEIGHT / 100 do
                love.graphics.line(x * 100, y * 100, x * 100 + 100, y * 100)
                love.graphics.line(x * 100, y * 100, x * 100, y * 100 + 100)
            end
        end

        local has_player = function() end
        for k, ship in ipairs(ships) do
            local x = WINDOW_WIDTH / 2 + ship.x / 100
            local y = WINDOW_HEIGHT / 2 + ship.y / 100
            if ship == player then
                has_player = function()
                    local x2, y2 = aly.move(x, y, player.angle, 20 + player.warp_charge * 3000)
                    love.graphics.setColor(aly.colors.darkseagreen)
                    love.graphics.circle('fill', x, y, 3)
                    love.graphics.setColor(aly.colors.white)
                    love.graphics.line(x, y, x2, y2)
                end
            else
                love.graphics.setColor(aly.colors.blue)
                love.graphics.circle('fill', x, y, 3)
            end
        end

        has_player()
    end
end
