extends Sprite

var bottom = Vector2(200, 240)
var top = Vector2(200, 47)

var speed = 70

func _ready():
	global_position = top
	beam()

func _on_Tween_tween_all_completed():
	queue_free()

func beam():
	var distance = position.distance_to(bottom)
	var time = distance / speed
	
	$Tween.interpolate_property(self, "position", global_position, bottom, time, Tween.TRANS_QUAD  , Tween.EASE_IN)
	$Tween.start()
