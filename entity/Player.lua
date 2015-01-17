local Animation = require 'Animation'
local PlayerDeath = require 'entity/PlayerDeath'

return function(x, y, name, controls)
  local walk_right = Animation({
    sprites = 'res/player_walk.png',
    sprite_width = 32,
    sprite_height = 32,
    offsets = {
      x = -8,
      y = -6
    },
    frames = { '1-8', 1 },
    frame_time = 0.05
  })

  local walk_left = Animation({
    sprites = 'res/player_walk.png',
    sprite_width = 32,
    sprite_height = 32,
    offsets = {
      x = -8,
      y = -6
    },
    frames = { '1-8', 1 },
    frame_time = 0.05,
    flip_horizontal = true
  })

  local idle_right = Animation({
    sprites = 'res/player_walk.png',
    sprite_width = 32,
    sprite_height = 32,
    offsets = {
      x = -8,
      y = -6
    },
    frames = { 1, 1 },
    frame_time = 0.05
  })

  local idle_left = Animation({
    sprites = 'res/player_walk.png',
    sprite_width = 32,
    sprite_height = 32,
    offsets = {
      x = -8,
      y = -6
    },
    frames = { 1, 1 },
    frame_time = 0.05,
    flip_horizontal = true
  })

  local jump_right = Animation({
    sprites = 'res/player_jump_right.png',
    sprite_width = 32,
    sprite_height = 32,
    offsets = {
      x = -8,
      y = -6
    },
    frames = { 1, 1 },
    frame_time = 0.05
  })

  local jump_left = Animation({
    sprites = 'res/player_jump_left.png',
    sprite_width = 32,
    sprite_height = 32,
    offsets = {
      x = -8,
      y = -6
    },
    frames = { 1, 1 },
    frame_time = 0.05
  })

  return {
    dies_when_off_stage = true,
    position = {
      x = x,
      y = y
    },
    velocity = {
      x = 0,
      y = 0
    },
    direction = 1,
    left_right = {
      left_key = controls.left,
      right_key = controls.right,
      speed = 100
    },
    has_mass = true,
    on_ground = true,
    jump = {
      jumping = false,
      speed = 350,
      key = controls.jump
    },
    size = {
      width = 16,
      height = 26
    },
    animation = idle_right,
    movement_animations = {
      walk_right = walk_right,
      walk_left = walk_left,
      air_right = jump_right,
      air_left = jump_left,
      idle_right = idle_right,
      idle_left = idle_left
    },
    add_to_world = true,
    player = true,
    respawn = {
      [{ 'position', 'x' }] = 20,
      [{ 'position', 'y' }] = 10,
      [{ 'direction' }] = 'right',
      [{ 'velocity', 'y' }] = 0
    },
    lives = 3,
    name = name,
    spawn_on_death = {
      function(entity)
        return PlayerDeath(entity.position.x, entity.position.y)
      end
    }
  }
end