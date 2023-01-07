extends KinematicBody2D

var bullet_on_cooldown = false

onready var path_follow = get_parent()
onready var tween = get_node("Tween")

var lanes = [0, 75, 150, 225, 300]
var prev_lane_index
var current_lane_index = 2
var animation: Animation

func _ready():
	path_follow.offset = lanes[current_lane_index]
	

func get_input():
	if Input.is_action_pressed("right"):
		if not tween.is_active():
			if current_lane_index != 4:
				prev_lane_index = current_lane_index
				current_lane_index += 1
				
				tween.interpolate_property(path_follow, "offset", lanes[prev_lane_index], lanes[current_lane_index], .2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				tween.start()
	if Input.is_action_pressed("left"):
		if not tween.is_active():
			if current_lane_index != 0:
				prev_lane_index = current_lane_index
				current_lane_index -= 1
				
				tween.interpolate_property(path_follow, "offset", lanes[prev_lane_index], lanes[current_lane_index], .2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				tween.start()
	
	if Input.is_action_just_pressed("shoot"):
		if not tween.is_active():
			shoot()

func _physics_process(delta):
	get_input()

func shoot():
	# TODO: Refactor to include CD but if a bullet is destroyed let the player fire another right away
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
