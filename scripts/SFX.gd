extends AudioStreamPlayer2D

func _ready():
	play()

func _on_AudioPlayer_finished():
	queue_free()
