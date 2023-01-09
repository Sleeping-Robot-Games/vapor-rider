extends Node2D

var speed = 400

var player = null

var target

func _ready():
	if not player:
		speed = 100
		$Area2D/Sprite.hide()
		$Area2D/AnimatedSprite.show()

func set_target(lane_index):
	var lane_group = 'top_lane' if player else 'bottom_lane'
	var lanes = get_tree().get_nodes_in_group(lane_group)
	for lane_pos in lanes:
		if 'Lane'+str(lane_index) in lane_pos.name:
			target = lane_pos.global_position

func fire(lane_index):
	set_target(lane_index)
	
	var distance = position.distance_to(target)
	var time = distance / speed
	
	$Tween.interpolate_property(self, "position", position, target, time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func _on_Area2D_body_entered(body):
	if body.has_method('dmg'):
		if player and "Enemy" in body.name:
			player.shoot_on_cooldown = false
			body.dmg()
			queue_free()
		elif not player and 'Player' in body.name and not body.disabled:
			body.dmg()
			queue_free()


func _on_Tween_tween_all_completed():
	queue_free()
