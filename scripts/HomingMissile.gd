extends Node2D

var random = RandomNumberGenerator.new()

var speed = 150

var target_lane = null
var target_pos = null
var target = null

var going_down_lane = false

onready var game = get_node('/root/Game')
onready var player = get_node('/root/Game/YSort/PlayerPath2D/PathFollow2D/Player')
onready var lanes = get_node('/root/Game/YSort/EnemyPositionPoints/Lanes').get_children()
onready var spawns = get_tree().get_nodes_in_group('missile_lane')
onready var homing_spawns = get_tree().get_nodes_in_group('homing_missile_spawns')
onready var bottom_lanes = get_tree().get_nodes_in_group('bottom_lane')

func fire():
	# spawn
	g.play_sfx("missile", 6)
	random.randomize()
	var n = random.randi_range(0,1)
	global_position = homing_spawns[n].global_position
	# begin moving
	if n == 0:
		move(1, 0)
	else:
		move(5, 0)

func move(lane, pos):
	target_lane = lane
	target_pos = pos
		
	# 3 means the bottom player row
	if target_pos == 3:
		for bottom_lane in bottom_lanes:
			if 'Lane'+str(lane) == bottom_lane.name:
				target = bottom_lane.global_position
	# otherwise we're in the normal lane rows
	else:
		for lane in lanes:
			if 'Lane'+str(target_lane)+'Pos'+str(target_pos) == lane.name:
				target = lane.global_position
	tween_me()

func tween_me():
	var distance = position.distance_to(target)
	var time = distance / speed
	
	$Tween.interpolate_property(self, "position", position, target, time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func dmg():
	game.emit_signal('homing_missile_dead')
	queue_free()

func _on_Tween_tween_all_completed():
	var player_lane = player.current_lane_index + 1
	var player_left = player_lane < target_lane
	var player_down = player_lane == target_lane
	var player_right = player_lane > target_lane
	
	if target_pos == 3:
		dmg()
	elif going_down_lane or player_down:
		going_down_lane = true
		move(target_lane, target_pos + 1)
	elif player_left:
		move(target_lane - 1, target_pos)
	elif player_right:
		move(target_lane + 1, target_pos)

func _on_Area2D_body_entered(body):
	if body.has_method('dmg'):
		if "Player" in body.name and not body.disabled:
			body.dmg()
			dmg()
