extends Node2D

var max_enemies = 3
var total_enemies = 15

func _ready():
	$CanvasLayer/LoadingMenu/AnimationPlayer.play('load')

func _on_EnemySpawnTimer_timeout():
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size() < max_enemies:
		var enemy_scene = load("res://scenes/Enemy.tscn")
		var new_enemy = enemy_scene.instance()
		get_node('YSort').add_child(new_enemy)
		new_enemy.spawn()


func _on_BeamTimer_timeout():
	var beam_scene = load("res://scenes/Beam.tscn")
	var new_beam = beam_scene.instance()
	get_node('Beams').add_child(new_beam)



func _on_StartTimer_timeout():
	$CanvasLayer/LoadingMenu.hide()
