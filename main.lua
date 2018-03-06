require 'aly'
require 'turtle'

require 'ship'
require 'ai'
require 'controls'
require 'graphics'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
WINDOW_WIDTH = 900
WINDOW_HEIGHT = 900
ACCEL = 10
DRAG = 0.9
ROTATION = math.pi * 3 / 2
WARP_ROTATION = math.pi / 10
WARP_SPEED = 20000

ships = {}

player = new_ship(300, 500, draw_ship)
table.insert(ships, player)

buddy = new_ship(600, 500, draw_ship)
table.insert(ships, buddy)

bullets = {}

camera = aly.Camera()
stars = make_stars()

function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
end

function love.keypressed(key)
    if key == 'escape' or key == 'q' then
        love.event.push('quit')
    -- elseif key == 'f11' then
    --     love.window.setFullscreen(not love.window.getFullscreen(), 'desktop')
    end
end

function love.update(dt)
    player.input = keyboard_or_gamepad()
    buddy.input = follow_behavior(buddy, player)

    for _, ship in ipairs(ships) do
        operate_ship(dt, ship)
        move_ship(dt, ship)
    end
end

function love.draw()
    draw_stars(stars, camera)

    camera.x = player.x
    camera.y = player.y
    camera.zoom = 0.5
    camera:push()

    for _, ship in ipairs(ships) do
        draw_ship(ship)
        draw_warp_meter(ship)
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

        local player_cur_x = WINDOW_WIDTH / 2 + player.x / 500
        local player_cur_y = WINDOW_HEIGHT / 2 + player.y / 500

        local buddy_cur_x = WINDOW_WIDTH / 2 + buddy.x / 500
        local buddy_cur_y = WINDOW_HEIGHT / 2 + buddy.y / 500

        local x2, y2 = aly.move(player_cur_x, player_cur_y, player.angle, 20 + player.warp_charge * 3000)
        love.graphics.line(player_cur_x, player_cur_y, x2, y2)
        love.graphics.circle(
            'fill',
            player_cur_x,
            player_cur_y,
            3
        )
        love.graphics.setColor(aly.colors.blue)
        love.graphics.circle(
            'fill',
            buddy_cur_x,
            buddy_cur_y,
            3
        )
    end
end
