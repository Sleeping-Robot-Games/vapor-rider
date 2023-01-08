extends KinematicBody2D

var shoot_on_cooldown = false

onready var path_follow = get_parent()
onready var tween = get_node("Tween")
onready var game = get_node('/root/Game')
onready var glitch_texture = load("res://shaders/glitch.png")

var lanes = [0, 80.5, 161, 241.5, 322]
var prev_lane_index
var current_lane_index = 2
var animation: Animation
var missiles = 3
var disabled = false

func _ready():
	path_follow.offset = lanes[current_lane_index]
	game.avail_missiles(missiles)
	game.player = self

func reset_position():
	path_follow.offset = lanes[2]

func get_input():
	if disabled:
		return
	if Input.is_action_pressed("right"):
		if not tween.is_active():
			if current_lane_index != 4:
				prev_lane_index = current_lane_index
				current_lane_index += 1
				tween.interpolate_property(path_follow, "offset", lanes[prev_lane_index], lanes[current_lane_index], .2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				tween.start()
				$Sprite.material.set_shader_param("offset_texture", glitch_texture)
	if Input.is_action_pressed("left"):
		if not tween.is_active():
			if current_lane_index != 0:
				prev_lane_index = current_lane_index
				current_lane_index -= 1
				tween.interpolate_property(path_follow, "offset", lanes[prev_lane_index], lanes[current_lane_index], .2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				tween.start()
				$Sprite.material.set_shader_param("offset_texture", glitch_texture)
	
	if Input.is_action_just_pressed("shoot"):
		if not tween.is_active() and not shoot_on_cooldown:
			shoot_bullet()
	elif Input.is_action_just_pressed("missile"):
		if not tween.is_active() and not shoot_on_cooldown:
			shoot_missile()

func _physics_process(_delta):
	get_input()

func shoot_bullet():
	var bullet_scene = preload("res://scenes/Bullet.tscn")
	spawn_projectile(bullet_scene)
	g.play_sfx("laser")

func shoot_missile():
	if missiles > 0:
		var missile_scene = preload("res://scenes/Missile.tscn")
		spawn_projectile(missile_scene)
		missiles -= 1
		game.avail_missiles(missiles)
	else:
		## TODO play no missile SFX
		pass

func spawn_projectile(projectile_scene):
	var projectile = projectile_scene.instance()
	projectile.global_position = Vector2(global_position.x, global_position.y - 15)
	projectile.player = self
	get_tree().get_root().get_node('Game/YSort').add_child(projectile)
	projectile.fire(current_lane_index + 1)
	
	# Shoot cooldown
	shoot_on_cooldown = true
	$ShootCooldown.start()

func dmg():
	game.lose_life()

func _on_ShootCooldown_timeout():
	shoot_on_cooldown = false

# apply glitch effect when changing lanes
func _on_Tween_tween_all_completed():
	$Sprite.material.set_shader_param("offset_texture", null)
	
	# Let the player shoot right after they switch lanes
	shoot_on_cooldown = false
