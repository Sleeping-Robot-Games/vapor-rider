extends Node2D

var speed = 10

var player: bool = true

var life_time = 2
var life_spawn = 0

var fire_direction: int

func _ready():
	if player:
		fire_direction = -speed
	else:
		fire_direction = speed

func _physics_process(delta):
	position.y += fire_direction
	# TODO: collide with enemies

	life_spawn += delta
	if life_spawn > life_time:
		queue_free()


func _on_Area2D_body_entered(body):
	print(body)
	if body.has_method('dmg'):
		body.dmg()
		queue_free()
		
