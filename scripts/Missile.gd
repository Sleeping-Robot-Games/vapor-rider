extends Node2D

var speed = 200

var player = null

var target = null

func _ready():
	pass

func set_target(lane_index):
	var lanes = get_tree().get_nodes_in_group('missile_lane')
	for spawn_pos in lanes:
		if 'Spawn'+str(lane_index) in spawn_pos.name:
			target = spawn_pos.global_position

func fire(lane_index):
	set_target(lane_index)
	
	var distance = position.distance_to(target)
	var time = distance / speed
	
	$Tween.interpolate_property(self, "position", position, target, time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func _on_Area2D_body_entered(body):
	if body.has_method('dmg'):
		if "Enemy" in body.name:
			body.dmg()
			queue_free()
		elif "Mothership" in body.name:
			## TODO: bonus points for mother ship?
			body.dmg()
			queue_free()


func _on_Tween_tween_all_completed():
	queue_free()
