extends Node2D

var max_enemies = 3

## TODO: A "Sector" is a level that is completed after all enemies are defeated
var sector = 1
## TODO: Need counter in the UI show how many enemies are left in the sector
var total_enemies = 15
## TODO: Show score in UI. Each enemy kill adds to score. Not sure on what the variations are yet
var score = 0

## TODO: Gameplay flow of completing one level then going to the next


## TODO: Recreate end of level gameplay Beamrider does with the mothership thing at the top of the level

func _ready():
	pass 

func _on_EnemySpawnTimer_timeout():
	spawn_enemy()

func spawn_enemy():
	# reset the timer in case fn is being called by a dying enemy
	$EnemySpawnTimer.stop()
	var enemies = []
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if !enemy.dying:
			enemies.append(enemy)
	if enemies.size() < max_enemies:
		var enemy_scene = load("res://scenes/Enemy.tscn")
		var new_enemy = enemy_scene.instance()
		get_node('YSort').add_child(new_enemy)
		new_enemy.spawn()
	$EnemySpawnTimer.start()

func spawn_astroids():
	## TODO: After level 1 astroids spawn that go all the way down to delivery points to hit player
	pass

func _on_BeamTimer_timeout():
	var beam_scene = load("res://scenes/Beam.tscn")
	var new_beam = beam_scene.instance()
	get_node('Beams').add_child(new_beam)
