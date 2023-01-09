extends Node2D

var speed = 100

var target

var directions = [Vector3(.4,-1,0), Vector3(.2,-1,0), Vector3(0,-1,0), Vector3(-.2,-1,0), Vector3(-.4,-1,0)]

func _ready():
	pass
		
func set_target(lane_index):
	$Particles2D.process_material.set('direction', directions[int(lane_index)-1])
	var lanes = get_tree().get_nodes_in_group('bottom_lane')
	for lane_pos in lanes:
		if 'Lane'+str(lane_index) in lane_pos.name:
			target = lane_pos.global_position

func fire(lane_index):
	set_target(lane_index)
	
	var distance = position.distance_to(target)
	var time = distance / speed
	
	$Tween.interpolate_property(self, "position", position, target, time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func dmg():
	queue_free()

func _on_Area2D_body_entered(body):
	if body.has_method('dmg'):
		if 'Player' in body.name and not body.disabled:
			body.dmg()
			queue_free()

func _on_Tween_tween_all_completed():
	queue_free()

