-- space tramp!

-- util
local aly = require 'aly'
require 'turtle'
require 'functional'

-- game code
require 'controls'
require 'ship'
local ai = require 'ai'
local collision = require 'collision'
require 'graphics'
require 'hud'

function love.load()
    -- WINDOW_WIDTH, WINDOW_HEIGHT = 1280, 720
    WINDOW_WIDTH, WINDOW_HEIGHT = 900, 900
    MAX_SPEED = 10
    ACCEL = 10
    DRAG = 0.3
    ROTATION = math.pi * 3 / 2
    WARP_ROTATION = math.pi / 14
    WARP_SPEED = 5000
    STAR_WARP_LINE_LENGTH = 150

    WARP_COLOR = aly.colors.dodgerblue
    WEAPON_COLOR = aly.colors.crimson
    SHIELD_COLOR = aly.colors.blueviolet

    camera = aly.Camera()
    camera.zoom = 0.4

    if love.system.getOS() == 'Android' or love.system.getOS() == 'iOS' then
        camera.zoom = 1
        WINDOW_WIDTH, WINDOW_HEIGHT = love.window.getDesktopDimensions()
    end

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)

    math.randomseed(os.time())

    objects = {}

    player = new_ship(0, 0, player_input, update_ship, draw_fancy)
    table.insert(objects, player)

    for i = 1, 5 do
        table.insert(objects, new_ship(
            math.random(-1000, 1000),
            math.random(-1000, 1000),
            ai.gen_follow_behavior(player),
            update_ship,
            gen_draw_random_enterprise()
        ))
    end

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
    require("libraries.lurker").update()

    for _, object in ipairs(objects) do
        object:update(dt)
    end

    objects = filter(not_dead, objects)

    collision.check(objects)
end

function love.draw()
    draw_stars(stars, camera)

    camera.x = player.physics.x
    camera.y = player.physics.y
    -- camera.zoom = 0.5 - player.warp.charge * 0.2
    camera:push()

    for _, object in ipairs(objects) do
        object:draw()
    end

    camera:pop()

    if player.input.nav then
        draw_nav(objects)
    end

    draw_meter(player.warp.fuel, player.weapon.energy, player.shields.charge)

    aly.draw_fps()
end
