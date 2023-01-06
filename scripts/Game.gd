extends Node2D

var max_enemies = 3

func _ready():
	pass 

func _on_EnemySpawnTimer_timeout():
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size() < max_enemies:
		var enemy_scene = load("res://scenes/Enemy.tscn")
		var new_enemy = enemy_scene.instance()
		get_node('YSort').add_child(new_enemy)
		new_enemy.spawn()
