local bump = require 'lib/bump/bump'
local anim8 = require 'lib/anim8/anim8'
local Scene = require 'scene'
local Animation = require 'Animation'
local Map = require 'Map'

local scene

local world = bump.newWorld()

local key_pressed = {}

local gravity = 900

function update_jump(scene, dt)
  for entity in pairs(scene:entities_with('animation', 'position', 'size', 'jump')) do
    if entity.on_ground then
      if entity.jump.jump_rel then
        entity.velocity.y = entity.jump.jump_acceleration
        entity.jump.jumping = true
        entity.jump.jump_rel = false
        entity.jump.jump_timer = 0.065
      end
    elseif entity.jump.jump_rel == false and entity.jump.jump_timer > 0 then
      entity.velocity.y = entity.velocity.y + entity.jump.jump_acceleration * dt
    else
      entity.jump.jump_rel = false
    end

    if key_pressed[entity.jump.key] then
      entity.jump.jump_rel = true
    end

    if entity.jump.jump_timer > 0 then
      entity.jump.jump_timer = entity.jump.jump_timer - dt
    end
  end
end

function update_gravity(scene, dt)
  for entity in pairs(scene:entities_with('has_mass', 'velocity')) do
    entity.velocity.y = entity.velocity.y + gravity * dt
  end
end

function spawn_player(scene, x, y, controls)
  local sprites = love.graphics.newImage('res/sprite.png')

  local a8 = anim8.newGrid(32, 32, sprites:getWidth(), sprites:getHeight())
  local walk_right = anim8.newAnimation(a8('1-8', 1), 0.1)
  local walk_left = anim8.newAnimation(a8('8-1', 1), 0.1); walk_left:flipH()
  local jump_right = anim8.newAnimation(a8(4, 1), 0.1)
  local jump_left = anim8.newAnimation(a8(4, 1), 0.1); jump_left:flipH()
  local idle_right = anim8.newAnimation(a8(1, 1), 0.1)
  local idle_left = anim8.newAnimation(a8(1, 1), 0.1); idle_left:flipH()

  local entity = scene:new_entity({
    dies_when_off_stage = true,
    position = {
      x = x,
      y = y
    },
    velocity = {
      x = 0,
      y = 0
    },
    acceleration = {
      x = 0,
      y = 0
    },
    direction = 'right',
    left_right = {
      left_key = controls.left,
      right_key = controls.right,
      speed = 100
    },
    has_mass = true,
    on_ground = true,
    jump = {
      jumping = false,
      jump_rel = false,
      jump_acceleration = -350,
      jump_timer = 0,
      key = controls.jump
    },
    size = {
      width = 16,
      height = 28
    },
    animation = Animation(
      sprites,
      {
        x = -8,
        y = -4
      },
      {
        walk_right = walk_right,
        walk_left = walk_left,
        air_right = jump_right,
        air_left = jump_left,
        idle_right = idle_right,
        idle_left = idle_left
      },
      'idle_right'
    ),
    movement_animations = {
      walk_right = 'walk_right',
      walk_left = 'walk_left',
      air_right = 'air_right',
      air_left = 'air_left',
      idle_right = 'idle_right',
      idle_left = 'idle_left'
    }
  })

  world:add(entity, entity.position.x, entity.position.y, entity.size.width, entity.size.height)
end

function check_collisions(entity, dx, dy)
  local size = entity.size
  local position = entity.position
  local velocity = entity.velocity
  entity.on_ground = false
  for _, collision in pairs(world:check(entity, position.x + dx, position.y + dy) or {}) do
    local obj = collision.other
    if (position.y + size.height - 0.5) <= obj.position.y and (position.y + size.height + dy) > obj.position.y then
      entity.on_ground = true
      entity.jump.jumping = false
      velocity.y = 0
      dy = -(position.y + size.height - obj.position.y)
      break
    end
  end

  return dx, dy
end

function render_animation(scene)
  for entity in pairs(scene:entities_with('animation', 'position')) do
    entity.animation:render(entity.position.x, entity.position.y)
  end
end

function render_background(scene)
  for entity in pairs(scene:entities_with('background')) do
    love.graphics.draw(entity.background)
  end
end

function render_map(scene)
  for entity in pairs(scene:entities_with('map')) do
    entity.map:draw()
  end
end

function update_animations(scene, dt)
  for entity in pairs(scene:entities_with('animation')) do
    entity.animation:update(dt)
  end
end

function update_position(scene, dt)
  for entity in pairs(scene:entities_with('velocity', 'position', 'size')) do
    local dy = entity.velocity.y * dt
    local dx = entity.velocity.x * dt

    dx, dy = check_collisions(entity, dx, dy)

    entity.position.y = entity.position.y + dy
    entity.position.x = entity.position.x + dx

    world:move(entity, entity.position.x, entity.position.y, entity.size.width, entity.size.height)
  end
end

function die_when_off_stage(scene, dt)
  local map_height
  local tile_height

  for entity in pairs(scene:entities_with('map')) do
    map_height = entity.map.height
    tile_height = entity.map.tileHeight
  end

  for entity in pairs(scene:entities_with('dies_when_off_stage', 'position', 'velocity')) do
    if entity.position.y > map_height * tile_height then
      entity.position.x = 20
      entity.position.y = 10
      entity.direction = 'right'
      entity.velocity.y = 0
    end
  end
end

function update_left_right(scene, dt)
  for entity in pairs(scene:entities_with('animation', 'position', 'left_right', 'jump', 'direction')) do
    if love.keyboard.isDown(entity.left_right.left_key) then
      entity.velocity.x = -entity.left_right.speed
      entity.direction = 'left'
    elseif love.keyboard.isDown(entity.left_right.right_key) then
      entity.velocity.x = entity.left_right.speed
      entity.direction = 'right'
    else
      entity.velocity.x = 0
    end
  end
end

function update_movement_animation(scene, dt)
  for entity in pairs(scene:entities_with('animation', 'velocity', 'on_ground', 'direction', 'movement_animations')) do
    if entity.velocity.x < 0 then
      if entity.on_ground then
        entity.animation:select(entity.movement_animations.walk_left)
      else
        entity.animation:select(entity.movement_animations.air_left)
      end
    elseif entity.velocity.x > 0 then
      if entity.on_ground then
        entity.animation:select(entity.movement_animations.walk_right)
      else
        entity.animation:select(entity.movement_animations.air_right)
      end
    else
      if entity.direction == 'right' then
        entity.animation:select(entity.movement_animations.idle_right)
      else
        entity.animation:select(entity.movement_animations.idle_left)
      end
    end
  end
end

function reset_keys()
  key_pressed = {}
end

function love.keypressed(k)
  key_pressed[k] = true
end

function love.load()
  scene = Scene()

  scene:add_render_system(render_background)
  scene:add_render_system(render_map)
  scene:add_render_system(render_animation)

  scene:add_update_system(update_jump)
  scene:add_update_system(update_left_right)
  scene:add_update_system(update_movement_animation)
  scene:add_update_system(update_gravity)
  scene:add_update_system(update_position)
  scene:add_update_system(die_when_off_stage)
  scene:add_update_system(update_animations)
  scene:add_update_system(reset_keys)

  scene:new_entity({
    background = love.graphics.newImage('res/background.png'),
    map = Map(world, 'res/map.tmx')
  })

  spawn_player(scene, 20, 10, { left = 'left', right = 'right', jump = 'up' })
  spawn_player(scene, 50, 10, { left = 'z', right = 'x', jump = 's' })
end

function love.draw()
  scene:render()
end

function love.update(dt)
  scene:update(dt)
end
