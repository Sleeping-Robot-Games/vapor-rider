extends Node2D

var speed = 100

var type = "lets_go_crazy"

onready var game = get_node('/root/Game')

var target

func _ready():
	## TODO: multiple types
	pass

func set_target(lane_index):
	var lane_group = 'bottom_lane'
	var lanes = get_tree().get_nodes_in_group(lane_group)
	for lane_pos in lanes:
		if 'Lane'+str(lane_index) in lane_pos.name:
			target = lane_pos.global_position

func spawn(lane_index):
	set_target(lane_index)
	
	var distance = position.distance_to(target)
	var time = distance / speed
	
	$Tween.interpolate_property(self, "position", position, target, time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func _on_Area2D_body_entered(body):
	if "Player" in body.name and not body.disabled:
		game.power_up(type)
		queue_free()

func _on_Tween_tween_all_completed():
	queue_free()
