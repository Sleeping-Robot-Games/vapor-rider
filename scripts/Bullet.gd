extends Node2D

var speed = 4

var player: bool = true

var target

func _ready():
	pass
		
func set_target(lane_index):
	var lane_group = 'top_lane' if player else 'bottom_lane'
	var lanes = get_tree().get_nodes_in_group(lane_group)
	for lane_pos in lanes:
		if 'Lane'+str(lane_index) in lane_pos.name:
			target = lane_pos.global_position
			
func fire(lane_index):
	## TODO: Switch from tween to normal translate movement to keep constant speed
	set_target(lane_index)
	$Tween.interpolate_property(self, "position", global_position, target, .5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	$Tween.start()


func _on_Area2D_body_entered(body):
	if body.has_method('dmg'):
		if player and "Enemy" in body.name:
			body.dmg()
			queue_free()
		elif not player and 'Player' in body.name:
			body.dmg()
			queue_free()


func _on_Tween_tween_all_completed():
	queue_free()
