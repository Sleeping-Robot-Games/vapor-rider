extends KinematicBody2D

var shoot_on_cooldown = false

onready var path_follow = get_parent()
onready var tween = get_node("Tween")
onready var game = get_node('/root/Game')

var lanes = [0, 80.5, 161, 241.5, 322]
var prev_lane_index
var current_lane_index = 2
var animation: Animation
var missiles = 3
var disabled = false
var has_armor = false

var speed = .15

var shots_fired = 0

func _ready():
	path_follow.offset = lanes[current_lane_index]
	game.avail_missiles(missiles)
	game.player = self

func reset_position():
	path_follow.offset = lanes[2]
	current_lane_index = 2

func get_input():
	if disabled:
		return
	if Input.is_action_pressed("right"):
		if not tween.is_active():
			if current_lane_index != 4:
				prev_lane_index = current_lane_index
				current_lane_index += 1
				tween.interpolate_property(path_follow, "offset", lanes[prev_lane_index], lanes[current_lane_index], speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				tween.start()
	if Input.is_action_pressed("left"):
		if not tween.is_active():
			if current_lane_index != 0:
				prev_lane_index = current_lane_index
				current_lane_index -= 1
				tween.interpolate_property(path_follow, "offset", lanes[prev_lane_index], lanes[current_lane_index], speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				tween.start()
	
	if Input.is_action_just_pressed("shoot"):
		if not shoot_on_cooldown:
			shoot_bullet()
	elif Input.is_action_just_pressed("missile"):
		if not shoot_on_cooldown:
			shoot_missile()

func _physics_process(_delta):
	get_input()

func shoot_bullet():
	shots_fired += 1
	var bullet_scene = preload("res://scenes/Bullet.tscn")
	spawn_projectile(bullet_scene)
	g.play_sfx("laser")

func shoot_missile():
	shots_fired += 1
	if missiles > 0:
		var missile_scene = preload("res://scenes/Missile.tscn")
		spawn_projectile(missile_scene)
		missiles -= 1
		game.avail_missiles(missiles)
	else:
		g.play_sfx("no_more_missiles", 6)

func spawn_projectile(projectile_scene):
	var projectile = projectile_scene.instance()
	projectile.global_position = Vector2(global_position.x, global_position.y - 15)
	projectile.player = self
	get_tree().get_root().get_node('Game/YSort').add_child(projectile)
	projectile.fire(current_lane_index + 1)
	
	# Shoot cooldown
	shoot_on_cooldown = true
	$ShootCooldown.start()

func chromify():
	has_armor = true
	$Sprite.frame = 1

func dechromify():
	has_armor = false
	$Sprite.frame = 0

func dmg():
	if has_armor:
		dechromify()
		g.play_sfx("player_hit_armor", 7)
	else:
		$Engine.emitting = false
		$Exhaust.emitting = false
		$Exhaust2.emitting = false
		game.lose_life()
		g.play_sfx("player_hit", 7)
		#TODO: Show glitch effect for like 2 seconds

func alive():
	$Engine.emitting = true
	$Exhaust.emitting = true
	$Exhaust2.emitting = true

func _on_ShootCooldown_timeout():
	shoot_on_cooldown = false


func _on_Tween_tween_all_completed():
	# Let the player shoot right after they switch lanes
	shoot_on_cooldown = false
