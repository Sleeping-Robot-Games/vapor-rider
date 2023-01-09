extends Node2D

var random = RandomNumberGenerator.new()

var speed = 100

var type

onready var game = get_node('/root/Game')

var target

func _ready():
	$H2O.visible = false
	$Chrome.visible = false
	$W1nd0ze.visible = false
	random.randomize()
	var n = random.randi_range(1, 3)
	if n == 1:
		type = "nectar_of_the_gods"
		$H2O.visible = true
	elif n == 2:
		type = "everything_is_chrome"
		$Chrome.visible = true
	elif n == 3:
		type = "lets_go_crazy"
		$W1nd0ze.visible = true
		
		

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
