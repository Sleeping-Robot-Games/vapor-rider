extends CanvasLayer

onready var player = get_node('/root/Game/YSort/PlayerPath2D/PathFollow2D/Player')

func _ready():
	player.disabled = true
	$LoadingMenu/AnimationPlayer.play("load")

func _input(event):
	if $StartMenu.visible:
		if Input.is_action_just_pressed("shoot"):
			$StartMenu.visible = false
			get_parent().start_game()
			

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'load':
		$LoadingMenu.visible = false
		$StartMenu/AnimationPlayer.play("title")
	if anim_name == 'title':
		$StartMenu/Space.visible = true
