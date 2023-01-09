extends Node2D

var speed = 400

var player = null

var target = null

var item = false

func _ready():
	if item:
		speed = 200

func set_target(lane_index):
	var lanes = get_tree().get_nodes_in_group('missile_lane')
	for spawn_pos in lanes:
		if 'Spawn'+str(lane_index) in spawn_pos.name:
			target = spawn_pos.global_position

func fire(lane_index, cdrom = false):
	if cdrom:
		$Area2D/Sprite.hide()
		$Area2D/Chrome.hide()
		$Area2D/AnimatedSprite.show()
	else:
		g.play_sfx("missile", 6)
	set_target(lane_index)
	
	var distance = position.distance_to(target)
	var time = distance / speed
	
	$Tween.interpolate_property(self, "position", position, target, time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func _on_Area2D_body_entered(body):
	if body.has_method('dmg'):
		if "Enemy" in body.name or "Mothership" in body.name or 'Asteroid' in body.name:
			body.dmg()
			queue_free()


func _on_Tween_tween_all_completed():
	queue_free()


func _on_Area2D_area_entered(area):
	var node = area.get_parent()
	if 'Asteroid' in node.name or 'Homing' in node.name:
		node.dmg()
		queue_free()
