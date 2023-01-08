extends KinematicBody2D

var random = RandomNumberGenerator.new()

export var points = 100

onready var tween = get_node("Tween")
onready var game = get_node('/root/Game')

var spawn_pos = Vector2(450, 42)
var target_pos = Vector2(-50, 42)

var spawn_pos_points = []
var lane_pos_points = []
var prev_lane:Position2D
var current_lane: Position2D
var current_lane_num: int
var current_vert_num: int
var move_pos_animation
var dying = false

func spawn():
	global_position = spawn_pos
	tween.interpolate_property(self, "position", spawn_pos, target_pos, 10, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func dmg():
	game.mothership_killed(points)
	queue_free()

func _on_Tween_tween_all_completed():
	game.load_next_sector()
