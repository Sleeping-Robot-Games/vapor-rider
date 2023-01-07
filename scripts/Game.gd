extends Node2D

var max_enemies = 3

## TODO: A "Sector" is a level that is completed after all enemies are defeated
var sector = 1
## TODO: Need counter in the UI show how many left in the sector
var total_enemies = 15
## TODO: Show score in UI. Each enemy kill adds to score. Not sure on what the variations are
var score = 0

## TODO: Gameplay flow of completing one level then going to the next


## TODO: Recreate end of level gameplay Beamrider does with the mothership

func _ready():
	pass 

## TODO: When an enemy is killed we need to send out another right away instead just on timer
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
