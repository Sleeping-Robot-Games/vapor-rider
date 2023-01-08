extends CanvasLayer


func _ready():
	$LoadingMenu/AnimationPlayer.play("load")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'load':
		$LoadingMenu.visible = false
		$StartMenu/AnimationPlayer.play("title")
	if anim_name == 'title':
		$StartMenu/Space.visible = true
