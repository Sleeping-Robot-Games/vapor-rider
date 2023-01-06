extends KinematicBody2D

var random = RandomNumberGenerator.new()

onready var tween = get_node("Tween")

var spawn_pos_points = []
var lane_pos_points = []
var prev_lane_pos: Vector2
var current_lane_pos: Vector2

var move_pos_animation

	
func _ready():
	add_to_group("enemies")
	
	spawn_pos_points = get_tree().get_root().get_node('Game/YSort/EnemyPositionPoints/Spawns').get_children()
	lane_pos_points = get_tree().get_root().get_node('Game/YSort/EnemyPositionPoints/Lanes').get_children()

func _physics_process(delta):
	pass
	
func spawn():
	global_position = find_spawn_point()
	current_lane_pos = global_position
	move()
	
func move():
	prev_lane_pos = current_lane_pos
	current_lane_pos = find_new_lane_pos()
	
	tween.interpolate_property(self, "position", prev_lane_pos, current_lane_pos, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	
func shoot():
	var bullet_scene = preload("res://scenes/Bullet.tscn")
	var bullet = bullet_scene.instance()
	bullet.player = false
	bullet.global_position = Vector2(global_position.x, global_position.y + 20)
	get_parent().call_deferred('add_child', bullet)

func dmg():
	queue_free()

func find_spawn_point():
	random.randomize()
	var n = random.randi_range(0, 4)
	return spawn_pos_points[n].global_position 
	
func find_new_lane_pos():
	random.randomize()
	## TODO: Refactor to be smarter about changing lane pos
	## TODO: Enemies only change to the next lane over or go up or back
	## TODO: Add in spawn points as well to this
	var n = random.randi_range(0, lane_pos_points.size()-1)
	return lane_pos_points[n].global_position


func _on_Tween_tween_all_completed():
	var coin_toss = random.randi_range(0, 1)
	if coin_toss == 1:
		shoot()
	move()
