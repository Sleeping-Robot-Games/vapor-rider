extends CanvasLayer

onready var player = get_node('/root/Game/YSort/PlayerPath2D/PathFollow2D/Player')
onready var bgm = get_node('/root/Game/BGM')
onready var game = get_parent()

func _ready():
	if game.debug:
		$LoadingMenu.visible = false
		return 
	player.disabled = true
	$LoadingMenu/AnimationPlayer.play("load")
	bgm.stream = load("res://audio/bgm/main_menu.mp3")
	bgm.play()

func _input(event):
	if $LoadingMenu.visible:
		if Input.is_action_just_pressed("shoot"):
			pass
	elif $StartMenu.visible and not game.game_over:
		if Input.is_action_just_pressed("shoot"):
			$StartMenu.visible = false
			get_parent().start_game()

func play_title_menu():
	$StartMenu.visible = true
	$StartMenu/AnimationPlayer.play('title')

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'load':
		$LoadingMenu.visible = false
		$StartMenu/AnimationPlayer.play("title")
	if anim_name == 'title':
		$StartMenu/Space.visible = true
