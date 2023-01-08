extends Node

onready var game = get_node("/root/Game")

var random = RandomNumberGenerator.new()

func play_sfx(sound):
	var sfx_scene = load("res://scenes/SFX.tscn")
	var sfx = sfx_scene.instance()
	
	if sound == "laser":
		random.randomize()
		var n = random.randi_range(1, 5)
		sfx.stream = load("res://audio/sfx/laser"+str(n)+".mp3")
		game.call_deferred('add_child', sfx)
