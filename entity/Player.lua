local Animation = require 'utility/Animation'
local PlayerDeath = require 'entity/PlayerDeath'

return function(x, y, name, controls)
  local walk_right = Animation({
    sprites = 'res/player_walk_right.png',
    offsets = {
      x = -8,
      y = -6
    },
    frame_time = 0.05
  })

  local walk_left = Animation({
    sprites = 'res/player_walk_left.png',
    offsets = {
      x = -8,
      y = -6
    },
    frame_time = 0.05
  })

  local idle_right = Animation({
    sprites = 'res/player_idle_right.png',
    offsets = {
      x = -8,
      y = -6
    },
    frame_time = 0.05
  })

  local idle_left = Animation({
    sprites = 'res/player_idle_left.png',
    offsets = {
      x = -8,
      y = -6
    },
    frame_time = 0.05
  })

  local jump_right = Animation({
    sprites = 'res/player_jump_right.png',
    offsets = {
      x = -8,
      y = -6
    },
    frame_time = 0.05
  })

  local jump_left = Animation({
    sprites = 'res/player_jump_left.png',
    offsets = {
      x = -8,
      y = -6
    },
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
    respawn = function(entity)
      entity.position.x = x
      entity.position.y = y
      entity.direction = 1
      entity.velocity.y = 0
    end,
    lives = 3,
    name = name,
    on_death = function(scene, entity)
      scene:new_entity(PlayerDeath(entity.position.x, entity.position.y))
    end
  }
end
