extends Node2D

export var debug = false

var random = RandomNumberGenerator.new()

var player = null

var max_enemies = 3

var sector = 1
var total_enemies = 15
var score = 0
var lives = 3
var between_levels = false
var homing_missiles_fired = 0
var homing_missiles_destroyed = 0

var power_ups_collected = 0
var kill_count = 0
var mothership_kill_count = 0

var game_over = false

signal homing_missile_dead

onready var http_request = $HTTPRequest

func _ready():
	if debug:
		start_game()
	
	http_request.connect("request_completed", self, "_on_request_completed")
	
	connect("homing_missile_dead", self, 'on_homing_missile_dead')
	
	$CanvasLayer/Enemies.text = "%02d" % total_enemies
	$CanvasLayer/Sector.text = "SECTOR %02d" % sector

func _input(event):
	if game_over:
		if Input.is_action_just_pressed("enter"):
			submit_score()
			restart_game()

func start_game():
	$BGM.stream = load ("res://audio/bgm/combat.mp3")
	$BGM.play()
	$StartGameTimer.start()
	yield($StartGameTimer, "timeout")
	
	$EnemySpawnTimer.start()
	player.disabled = false

func _on_EnemySpawnTimer_timeout():
	spawn_enemy()

func on_homing_missile_dead():
	homing_missiles_destroyed += 1
	print(str(homing_missiles_destroyed) + " homing missiles destroyed")
	if homing_missiles_destroyed == 6:
		load_next_sector()
		$CanvasLayer/AnimationPlayer.play("new_sector")
		homing_missiles_destroyed = 0

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
		if player.disabled:
			new_enemy.ceasefire = true
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
	if homing_missiles_fired == 5:
		$MothershipTimer.stop()
	var homing_missile_scene = load('res://scenes/HomingMissile.tscn')
	var new_h_missile = homing_missile_scene.instance()
	# mother ship homing missiles randomly spawn from left or right and goes to the current_lane the player is in
	get_node("YSort").call_deferred('add_child', new_h_missile)
	new_h_missile.call_deferred('fire')
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
	kill_count += 1
	$CanvasLayer/Score.text = "%06d" % score
	total_enemies -= 1
	if total_enemies < 0:
		total_enemies = 0
	$CanvasLayer/Enemies.text = "%02d" % total_enemies
	if total_enemies > 0:
		pass
		#spawn_enemy()
	else:
		$AsteroidTimer.stop()
		spawn_mothership()

func mothership_killed(points):
	score += points
	mothership_kill_count += 1
	$CanvasLayer/Score.text = "%06d" % score

func load_next_sector():
	sector += 1
	total_enemies = 15
	$CanvasLayer/SectorTitle.text = "SECTOR %02d" % sector
	$CanvasLayer/Sector.text = "SECTOR %02d" % sector
	$CanvasLayer/Enemies.text = "%02d" % total_enemies
	player.missiles = 3
	avail_missiles(3)
	homing_missiles_fired = 0
	
func start_next_sector():
	if sector >= 2:
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
	if lives <= 0:
		game_over()
	else:
		$PlayerReloadTimer.start()

func power_up(type):
	score += 20
	power_ups_collected += 1
	if type == "nectar_of_the_gods":
		if lives < 3:
			lives += 1
			update_lives_ui()
			g.play_sfx("H2O", 9)
		else:
			## TODO: different sfx?
			g.play_sfx("no_more_missiles")
	elif type == "everything_is_chrome":
		g.play_sfx("chromify", 9)
		player.chromify()
	elif type == "lets_go_crazy":
		g.play_sfx("lets_go_crazy", 9)
		$PowerUpClips/AnimatedSprite.visible = true
		$PowerUpClips/AnimatedSprite.playing = true
		var lanes = get_tree().get_nodes_in_group('bottom_lane')
		for n in range(0,5):
			var missile_scene = preload("res://scenes/Missile.tscn")
			var cdrom = missile_scene .instance()
			cdrom.item = true
			cdrom.global_position = Vector2(lanes[n].global_position.x, lanes[n].global_position.y + 15)
			get_tree().get_root().get_node('Game/YSort').call_deferred('add_child', cdrom)
			cdrom.call_deferred('fire', n + 1, true)
		

func game_over():
	game_over = true
	$CanvasLayer/GameOver.show()
	$EnemySpawnTimer.stop()
	$AsteroidTimer.stop()
	$BGM.stream = load ("res://audio/bgm/main_menu.mp3")
	$BGM.play()
	
func submit_score():
	var username = $CanvasLayer/GameOver/LineEdit.text.to_lower()
	if username.empty():
		return # Don't submit a score if there's no name entered
	var score_url = 'https://high-score-api.onrender.com/api/v1/games/65fe0a2f7dbc06d1f4b97e0c/scores'
	var headers = ["Content-Type: application/json"]
	var score_data = [
		{
			"username": username,
			"scoreType": 'Score',
			"score": score
		},
		{
			"username": username,
			"scoreType": 'Kills',
			"score": kill_count
		},
		{
			"username": username,
			"scoreType": 'Power Ups',
			"score": power_ups_collected
		},
		{
			"username": username,
			"scoreType": 'Mothership kills',
			"score": mothership_kill_count
		},
		{
			"username": username,
			"scoreType": 'Shots fired',
			"score": player.shots_fired
		}
	]
	var json_data = JSON.print(score_data)
	http_request.request(score_url, headers, true, HTTPClient.METHOD_POST, json_data)
	
func _on_request_completed(result, response_code, headers, body):
	print(response_code)
	

func restart_game():
	$CanvasLayer/GameOver.hide()
	game_over = false
	score = 0
	power_ups_collected = 0
	kill_count = 0
	mothership_kill_count = 0
	player.shots_fired = 0
	$CanvasLayer/Score.text = "%06d" % score
	sector = 1
	$CanvasLayer/Sector.text = "SECTOR %02d" % sector
	total_enemies = 15
	$CanvasLayer/Enemies.text = "%02d" % total_enemies
	player.missiles = 3
	lives = 3
	update_lives_ui()
	avail_missiles(3)
	homing_missiles_destroyed = 0
	for enemy in get_tree().get_nodes_in_group('enemies'):
		enemy.queue_free()
	for mothership_parts in get_tree().get_nodes_in_group('mothership_parts'):
		mothership_parts.queue_free()
	player.get_node('Sprite').modulate = Color(1, 1, 1)
	player.reset_position()
	player.alive()
	
	$CanvasLayer.play_title_menu()

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
	player.alive()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.ceasefire = false

func _on_AnimatedSprite_animation_finished():
	$PowerUpClips/AnimatedSprite.visible = false

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'new_sector':
		start_next_sector()
