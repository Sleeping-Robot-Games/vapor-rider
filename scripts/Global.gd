extends Node

onready var game = get_node("/root/Game")

var random = RandomNumberGenerator.new()

func play_sfx(sound, dB = 0):
	var sfx_scene = load("res://scenes/SFX.tscn")
	var sfx = sfx_scene.instance()
	sfx.volume_db = dB
	
	if sound == "laser":
		random.randomize()
		var n = random.randi_range(1, 5)
		sfx.stream = load("res://audio/sfx/laser"+str(n)+".mp3")
	elif sound == "missile":
		sfx.stream = load("res://audio/sfx/rocket_fire.mp3")
	elif sound == "no_more_missiles":
		sfx.stream = load("res://audio/sfx/no_more_missiles.mp3")
	elif sound == "H2O":
		sfx.stream = load("res://audio/sfx/water_bottle.mp3")
	elif sound == "lets_go_crazy":
		sfx.stream = load("res://audio/sfx/drink.mp3")
	elif sound == "chromify":
		sfx.stream = load("res://audio/sfx/apply_chrome.mp3")
	elif sound == "player_hit":
		sfx.stream = load("res://audio/sfx/shield_critical_alarm.mp3")
	elif sound == "player_hit_armor":
		sfx.stream = load("res://audio/sfx/chrome_deflect.mp3")
	
	
	
	game.call_deferred('add_child', sfx)
