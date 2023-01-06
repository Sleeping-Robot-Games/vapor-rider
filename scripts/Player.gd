extends KinematicBody2D

var bullet_on_cooldown = false

onready var path_follow = get_parent()
onready var animation_player = get_parent().get_node("AnimationPlayer")

var lanes = [0, 90, 180, 270, 360]
var prev_lane_index
var current_lane_index = 2
var animation: Animation

func _ready():
	animation = animation_player.get_animation('move_lane')
	path_follow.offset = lanes[current_lane_index]

func get_input():
	if Input.is_action_pressed("right"):
		if not animation_player.is_playing():
			if current_lane_index != 4:
				prev_lane_index = current_lane_index
				current_lane_index += 1
				
				animation.track_set_key_value(0, 0, lanes[prev_lane_index])
				animation.track_set_key_value(0, 1, lanes[current_lane_index])
				
				animation_player.play("move_lane")
	if Input.is_action_pressed("left"):
		if not animation_player.is_playing():
			if current_lane_index != 0:
				prev_lane_index = current_lane_index
				current_lane_index -= 1
				animation.track_set_key_value(0, 0, lanes[prev_lane_index])
				animation.track_set_key_value(0, 1, lanes[current_lane_index])
				
				animation_player.play("move_lane")
	
	if Input.is_action_just_pressed("shoot"):
		if not animation_player.is_playing():
			shoot()

func _physics_process(delta):
	get_input()

func shoot():
	if not bullet_on_cooldown:
		var bullet_scene = preload("res://scenes/Bullet.tscn")
		var bullet = bullet_scene.instance()
		bullet.global_position = Vector2(global_position.x, global_position.y - 20)
		get_tree().get_root().get_node('Game/YSort').call_deferred('add_child', bullet)
		# Bullet cooldown
		bullet_on_cooldown = true
		$ShootCooldown.start()


func dmg():
	pass

func _on_ShootCooldown_timeout():
	bullet_on_cooldown = false
