extends Node2D

var random = RandomNumberGenerator.new()

var speed = 150

var target = null
var current_lane_index

var going_down_lane = false

onready var game = get_node('/root/Game')
onready var player = get_node('/root/Game/YSort/PlayerPath2D/PathFollow2D/Player')

func _ready():
	game.connect('player_moved', self, 'handle_player_moved')
	
func set_spawn():
	random.randomize()
	var n = random.randi_range(0,1)
	var spawns = get_tree().get_nodes_in_group('homing_missle_spawns')
	global_position = spawns[n].global_position

func set_lane(lane_index):
	current_lane_index = lane_index
	var lanes = get_tree().get_root().get_node('Game/YSort/EnemyPositionPoints/Lanes').get_children()
	for lane in lanes:
		if 'Lane'+str(lane_index)+'Pos0' == lane.name:
			print(lane.name + " is being set")
			target = lane.global_position

func tween_me():
	var distance = position.distance_to(target)
	var time = distance / speed
	
	$Tween.interpolate_property(self, "position", position, target, time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func handle_player_moved():
	if not going_down_lane:
		set_lane(player.current_lane_index + 1)
		tween_me()

func fire(lane_index):
	set_spawn()
	set_lane(lane_index)
	tween_me()

func deliver():
	target = get_node('/root/Game/YSort/EnemyPositionPoints/Deliveries/Lane'+str(current_lane_index)).global_position
	tween_me()

func _on_Area2D_body_entered(body):
	if body.has_method('dmg'):
		if "Player" in body.name:
			body.dmg()
			queue_free()

func _on_Tween_tween_all_completed():
	if going_down_lane:
		queue_free()

	if player.current_lane_index + 1 == current_lane_index:
		going_down_lane = true
		deliver()
		
