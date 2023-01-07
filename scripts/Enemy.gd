extends KinematicBody2D

var random = RandomNumberGenerator.new()

onready var tween = get_node("Tween")

var spawn_pos_points = []
var lane_pos_points = []
var prev_lane:Position2D
var current_lane: Position2D
var current_lane_num: int
var current_vert_num: int

var move_pos_animation

	
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

	tween.interpolate_property(self, "scale", self.scale, Vector2(new_scale, new_scale), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "position", prev_lane.global_position, current_lane.global_position, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	tween.start()
	
func shoot():
	var bullet_scene = preload("res://scenes/Bullet.tscn")
	var bullet = bullet_scene.instance()
	bullet.global_position = Vector2(global_position.x, global_position.y + 15)
	get_parent().add_child(bullet)
	bullet.fire(current_lane_num)

func dmg():
	queue_free()

func find_spawn_point():
	random.randomize()
	var n = random.randi_range(0, 4)
	current_lane_num = n
	current_vert_num = -1
	## TODO: Use left and right spawn points as well - only pos0 for lane0 and 4
	return spawn_pos_points[n] 
	
func find_new_lane_pos():
	# TODO: Make a 1/3 chance the enemy runs back up to the lane's spawn
	random.randomize()
	var lane_offset = random.randi_range(-1, 1)
	current_lane_num = min(4, max(0, current_lane_num + lane_offset))
	
	var spawn_included = -1 if lane_offset == 0 else 0
	var rand_pos = random.randi_range(0 + spawn_included, 2)
	current_vert_num = rand_pos
	
	if rand_pos == -1:
		for spawn in spawn_pos_points:
			if spawn.name == 'Spawn'+str(current_lane_num):
				return spawn
	else:
		for lane in lane_pos_points:
			if lane.name == 'Lane'+str(current_lane_num)+'Pos'+str(rand_pos):
				return lane


func _on_Tween_tween_all_completed():
	var coin_toss = random.randi_range(0, 1)
	if coin_toss == 1:
		shoot()
	move()
