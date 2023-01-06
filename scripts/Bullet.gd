extends Node2D

var speed = 4

var player: bool = true

var life_time = .55 # Length of lane
var life_spawn = 0

var fire_direction: int

func _ready():
	if player:
		speed = 5
		fire_direction = -speed
	else:
		speed = 2
		life_time = 2
		rotation_degrees = 180
		fire_direction = speed

func _physics_process(delta):
	position.y += fire_direction

	life_spawn += delta
	if life_spawn > life_time:
		queue_free()


func _on_Area2D_body_entered(body):
	if body.has_method('dmg'):
		if player and "Enemy" in body.name:
			body.dmg()
			queue_free()
		elif not player and 'Player' in body.name:
			body.dmg()
			queue_free()
		
