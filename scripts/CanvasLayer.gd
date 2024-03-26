extends CanvasLayer

onready var player = get_node('/root/Game/YSort/PlayerPath2D/PathFollow2D/Player')
onready var bgm = get_node('/root/Game/BGM')
onready var game = get_parent()

var canStart = false

func _ready():
	if game.debug:
		$LoadingMenu.visible = false
		return 
	player.disabled = true
	$LoadingMenu/AnimationPlayer.play("load")
	bgm.stream = load("res://audio/bgm/main_menu.mp3")
	bgm.play()

func _input(event):
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused
		$Effects/VHS.visible = get_tree().paused
		$Effects/TV.visible = !get_tree().paused
		$PauseLabel.visible = get_tree().paused
	if $LoadingMenu.visible:
		if Input.is_action_just_pressed("shoot"):
			pass
	elif $StartMenu.visible and canStart and not game.game_over:
		if Input.is_action_just_pressed("shoot"):
			$StartMenu.visible = false
			get_parent().start_game()
		if Input.is_action_just_pressed("h"):
			$StartMenu.visible = false
			$HighScores.visible = true
	elif $HighScores.visible and canStart and not game.game_over:
		if Input.is_action_just_pressed("shoot"):
			$HighScores.visible = false
			$StartMenu.visible = true

func play_title_menu():
	canStart = false
	$StartMenu.visible = true
	$StartMenu/AnimationPlayer.play('title')

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'load':
		$LoadingMenu.visible = false
		$StartMenu/AnimationPlayer.play("title")
	if anim_name == 'title':
		$StartMenu/Space.visible = true
		$StartMenu/Highscores.visible = true
		canStart = true
