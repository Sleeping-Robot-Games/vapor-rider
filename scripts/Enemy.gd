extends KinematicBody2D

var path_follow: PathFollow2D

var speed = 250

func _ready():
	path_follow = get_parent()

func _physics_process(delta):
	path_follow.set_offset(path_follow.get_offset() + speed * delta)

func dmg():
	queue_free()
