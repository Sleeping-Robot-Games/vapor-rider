extends KinematicBody2D

var random = RandomNumberGenerator.new()

export var points = 48

onready var tween = get_node("Tween")
onready var game = get_node('/root/Game')

var spawn_pos_points = []
var lane_pos_points = []
var prev_lane:Position2D
var current_lane: Position2D
var current_lane_num: int
var current_vert_num: int
var move_pos_animation
var dying = false
var ceasefire = false
	
func _ready():
	add_to_group("enemies")
	
	spawn_pos_points = get_tree().get_root().get_node('Game/YSort/EnemyPositionPoints/Spawns').get_children()
	lane_pos_points = get_tree().get_root().get_node('Game/YSort/EnemyPositionPoints/Lanes').get_children()

func _physics_process(delta):
	pass
	
func spawn():
	current_lane = find_spawn_point()
	scale = Vector2(.09, .09)
	global_position = current_lane.global_position
	move()

func move():
	prev_lane = current_lane
	current_lane = find_new_lane_pos()
	
	# Calculate the scale based on the current vertical number
	var new_scale = ([0.09, 0.15, 0.21, 0.27, 0.3])[clamp(current_vert_num + 1, 0, 4)]

	tween.interpolate_property(self, "scale", scale, Vector2(new_scale, new_scale), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "position", prev_lane.global_position, current_lane.global_position, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	tween.start()
	
func shoot():
	var bullet_scene = preload("res://scenes/Bullet.tscn")
	var bullet = bullet_scene.instance()
	bullet.global_position = Vector2(global_position.x, global_position.y + 15)
	get_parent().add_child(bullet)
	bullet.fire(current_lane_num)

func dmg():
	# TODO: Flash background on death
	# TODO: Death animation
	dying = true
	game.enemy_killed(points)
	# 1/6 chance to drop power up
	random.randomize()
	var drop_powerup = random.randi_range(1,6)
	if drop_powerup == 6:
		var powerup_scene = preload("res://scenes/PowerUp.tscn")
		var powerup = powerup_scene.instance()
		powerup.global_position = Vector2(global_position.x, global_position.y)
		get_parent().call_deferred('add_child', powerup)
		powerup.call_deferred('spawn', current_lane_num)
	queue_free()

func find_spawn_point():
	random.randomize()
	var n = random.randi_range(0, 6)
	current_lane_num = n
	current_vert_num = -1
	return spawn_pos_points[n]
	
func find_new_lane_pos():
	# If an enemy just spawned in outer lane, they can only move inward to pos0
	if current_lane_num == 0 or current_lane_num == 6:
		current_lane_num = 1 if current_lane_num == 0 else 5
		current_vert_num = 0
		for lane in lane_pos_points:
			if lane.name == 'Lane'+str(current_lane_num)+'Pos'+str(current_vert_num):
				return lane
	
	# 1/3 chance the enemy runs back up to the lane's spawn
	random.randomize()
	var back_to_spawn = random.randi_range(-1, 1)
	if back_to_spawn == 1:
		current_vert_num = 0
		var inner_spawn_points = spawn_pos_points.slice(1, 5)
		for spawn in inner_spawn_points:
			if spawn.name == 'Spawn'+str(current_lane_num):
				return spawn
	
	# 2/3 chance to move to a random pos along current or adjascent lane
	random.randomize()
	var lane_offset = random.randi_range(-1, 1)
	current_lane_num = min(5, max(1, current_lane_num + lane_offset))
	current_vert_num = random.randi_range(0, 2)
	for lane in lane_pos_points:
		if lane.name == 'Lane'+str(current_lane_num)+'Pos'+str(current_vert_num):
			return lane


func _on_Tween_tween_all_completed():
	var coin_toss = random.randi_range(0, 1)
	if not ceasefire and coin_toss == 1:
		shoot()
	move()
