-- space tramp!

local lurker = require("libraries.lurker.lurker")
local timer = require('libraries.hump.timer')
require('libraries.functional')

local aly = require('util.aly')
local misc = require('util.misc')

local controls = require('controls')
local spaceship = require('spaceship')
local ai = require('ai')
local collision = require('collision')
local graphics = require('graphics')
local hud = require('hud')
local network_node = require('network_node')

function love.load()
    math.randomseed(os.time())

    MAX_SPEED = 10
    ACCEL = 10
    DRAG = 0.15
    ROTATION = math.pi * 3 / 2
    WARP_ROTATION = math.pi / 14
    WARP_SPEED = 15000
    STAR_WARP_LINE_LENGTH = 150

    camera = aly.Camera()

    objects = {}

    player = spaceship.new({
        x = 0,
        y = 0,
        behavior = controls.player_input,
        draw = spaceship.gen_draw_random_enterprise()
    })
    table.insert(objects, player)

    for i = 1, 5 do
        table.insert(objects, spaceship.new({
            behavior = ai.gen_follow_behavior(player)
        }))
    end

    local network = {}
    for i = 1, 5 do
        table.insert(network, network_node.new({
            x = math.random(-200000, 200000),
            y = math.random(-200000, 200000)
        }))
    end

    local i = 3
    while i > 0 do
        local n1 = aly.choice(network)
        local n2 = aly.choice(network)
        if n1 ~= n2 and not aly.contains_value(n1.neighbors, n2) then
            n1:attach(n2)
            i = i - 1
        end
    end

    for _, node in ipairs(network) do
        table.insert(objects, node)
    end

    stars = graphics.make_stars()
end

function love.keypressed(key)
    if key == 'escape' or key == 'q' then
        love.event.push('quit')
    elseif key == 'f11' then
        love.window.setFullscreen(not love.window.getFullscreen(), 'desktop')
    end
end

function love.update(dt)
    lurker.update()

    for _, object in ipairs(objects) do
        object:update(dt)
    end

    objects = filter(misc.not_dead, objects)

    collision.check(objects)
end

-- res = 16/9

function love.draw()
    graphics.draw_stars(stars, camera)

    camera.x = player.physics.x
    camera.y = player.physics.y
    camera.zoom = 0.5 * graphics.get_cam_zoom()
    camera:push()

    for _, object in ipairs(objects) do
        object:draw()
    end

    camera:pop()

    if player.input.nav then
        graphics.draw_nav(objects)
    end

    hud.draw_meter(
        player.warp.fuel,
        player.weapon.energy,
        player.shields.charge
    )

    aly.draw_fps()
end
