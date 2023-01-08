extends Node2D

export var debug = true

var random = RandomNumberGenerator.new()

var player = null

var max_enemies = 3

var sector = 1
var total_enemies = 15
var score = 0
var lives = 3
var between_levels = false
var homing_missiles_fired = 0

func _ready():
	if debug:
		start_game()
	$CanvasLayer/Enemies.text = "%02d" % total_enemies
	$CanvasLayer/Sector.text = "SECTOR %02d" % sector


func start_game():
	$StartGameTimer.start()
	yield($StartGameTimer, "timeout")
	
	$EnemySpawnTimer.start()
	player.disabled = false
	##spawn_mothership()

func restart_game():
	# Once all lives are lost, send back to main menu
	sector = 1
	$CanvasLayer/Sector.text = "SECTOR %02d" % sector
	total_enemies = 15
	$CanvasLayer/Enemies.text = "%02d" % total_enemies
	player.missiles = 3
	avail_missiles(3)

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
		get_node('YSort').call_deferred('add_child', new_enemy)
		new_enemy.call_deferred('spawn')
	$EnemySpawnTimer.start()

func spawn_mothership():
	var mothership_scene = load("res://scenes/Mothership.tscn")
	var new_mothership = mothership_scene.instance()
	get_node('YSort').call_deferred('add_child', new_mothership)
	new_mothership.call_deferred('spawn')
	$MothershipTimer.start()
	

func _on_MothershipTimer_timeout():
	if homing_missiles_fired > 4:
		$MothershipTimer.stop()
	var homing_missile_scene = load('res://scenes/HomingMissile.tscn')
	var new_h_missile = homing_missile_scene.instance()
	# mother ship homing missiles randomly spawn from left or right and goes to the current_lane the player is in
	get_node("YSort").call_deferred('add_child', new_h_missile)
	new_h_missile.call_deferred('fire')#, player.current_lane_index + 1)
	homing_missiles_fired += 1
	
func spawn_asteroid():
	if sector == 5:
		# Increase astroid frequency
		$AsteroidTimer.wait_time = 3
	if sector == 10:
		$AsteroidTimer.wait_time = 2
	if not between_levels and not player.disabled:
		random.randomize()
		var n = random.randi_range(0, 4)
		var spawn = get_tree().get_nodes_in_group('missile_lane')[n]
		var asteroid_scene = load('res://scenes/Asteroid.tscn')
		var new_asteroid = asteroid_scene.instance()
		new_asteroid.global_position = spawn.global_position
		get_node("YSort").call_deferred('add_child', new_asteroid)
		new_asteroid.call_deferred('fire', spawn.name[5])

func _on_AsteroidTimer_timeout():
	spawn_asteroid()

func enemy_killed(points):
	score += points
	$CanvasLayer/Score.text = "%06d" % score
	total_enemies -= 1
	$CanvasLayer/Enemies.text = "%02d" % total_enemies
	if total_enemies > 0:
		spawn_enemy()
	else:
		spawn_mothership()

func mothership_killed(points):
	score += points
	$CanvasLayer/Score.text = "%06d" % score
	## TODO: Load next sector after all the mothership missiles are gone not when mothership is dead
	load_next_sector()

func load_next_sector():
	## TODO: Play next level animation so the player knows when they complete one
	sector += 1
	$CanvasLayer/Sector.text = "SECTOR %02d" % sector
	total_enemies = 15
	$CanvasLayer/Enemies.text = "%02d" % total_enemies
	player.missiles = 3
	avail_missiles(3)
	if sector == 2:
		$AsteroidTimer.start()

func lose_life():
	player.get_node('AnimationPlayer').play('die')
	# Pause controls while it reloads the ship
	player.disabled = true
	# No enemies shoot during pause
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.ceasefire = true
	lives -= 1
	update_lives_ui()
	if lives == 0:
		game_over()
	else:
		$PlayerReloadTimer.start()

func power_up(type):
	if type == "lets_go_crazy":
		$PowerUpClips/AnimatedSprite.visible = true
		$PowerUpClips/AnimatedSprite.playing = true
		var lanes = get_tree().get_nodes_in_group('bottom_lane')
		for n in range(0,5):
			var missile_scene = preload("res://scenes/Missile.tscn")
			var cdrom = missile_scene .instance()			
			cdrom.global_position = Vector2(lanes[n].global_position.x, lanes[n].global_position.y + 15)
			get_tree().get_root().get_node('Game/YSort').call_deferred('add_child', cdrom)
			cdrom.call_deferred('fire', n + 1, true)

func game_over():
	# TODO: Implement reset option
	$CanvasLayer/GameOver.show()

func _on_BeamTimer_timeout():
	var beam_scene = load("res://scenes/Beam.tscn")
	var new_beam = beam_scene.instance()
	get_node('Beams').add_child(new_beam)

func avail_missiles(remaining):
	$CanvasLayer/Missile.visible = remaining > 0
	$CanvasLayer/Missile2.visible = remaining > 1
	$CanvasLayer/Missile3.visible = remaining > 2

func update_lives_ui():
	$CanvasLayer/Life.visible = lives > 0
	$CanvasLayer/Life2.visible = lives > 1
	$CanvasLayer/Life3.visible = lives > 2

func _on_PlayerReloadTimer_timeout():
	player.get_node('Sprite').modulate = Color(1, 1, 1)
	player.disabled = false
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.ceasefire = false

func _on_AnimatedSprite_animation_finished():
	$PowerUpClips/AnimatedSprite.visible = false

