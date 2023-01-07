extends Node2D

var max_enemies = 3

## TODO: A "Sector" is a level that is completed after all enemies are defeated
var sector = 1
var total_enemies = 15
var score = 0

## TODO: Gameplay flow of completing one level then going to the next


## TODO: Recreate end of level gameplay Beamrider does with the mothership thing at the top of the level

func _ready():
	$CanvasLayer/Enemies.text = "%02d" % total_enemies
	$CanvasLayer/Sector.text = "SECTOR %02d" % sector

func _on_EnemySpawnTimer_timeout():
	spawn_enemy()

func spawn_enemy():
	# reset the timer in case fn is being called by a dying enemy
	$EnemySpawnTimer.stop()
	var enemies = []
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if !enemy.dying:
			enemies.append(enemy)
	var living_enemies = enemies.size()
	if living_enemies < max_enemies and total_enemies - living_enemies > 0:
		var enemy_scene = load("res://scenes/Enemy.tscn")
		var new_enemy = enemy_scene.instance()
		get_node('YSort').add_child(new_enemy)
		new_enemy.spawn()
	$EnemySpawnTimer.start()

func spawn_astroids():
	## TODO: After level 1 astroids spawn that go all the way down to delivery points to hit player
	pass

func enemy_killed(points):
	score += points
	$CanvasLayer/Score.text = "%06d" % score
	total_enemies -= 1
	$CanvasLayer/Enemies.text = "%02d" % total_enemies
	spawn_enemy()

func _on_BeamTimer_timeout():
	var beam_scene = load("res://scenes/Beam.tscn")
	var new_beam = beam_scene.instance()
	get_node('Beams').add_child(new_beam)

func avail_missiles(remaining):
	$CanvasLayer/Missile.visible = remaining > 0
	$CanvasLayer/Missile2.visible = remaining > 1
	$CanvasLayer/Missile3.visible = remaining > 2

