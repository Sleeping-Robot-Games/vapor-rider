extends KinematicBody2D

var path_follow: PathFollow2D

var speed = 250

func _ready():
	path_follow = get_parent()

func _physics_process(delta):
	path_follow.set_offset(path_follow.get_offset() + speed * delta)

func dmg():
	queue_free()


func _on_MoveTimer_timeout():
	pass # Replace with function body.
	## NOTE: When moving LanePos4 will not be used. Created it for items to drop down to player
