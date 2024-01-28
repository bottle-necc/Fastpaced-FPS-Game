extends RayCast3D

signal hit
signal no_hit

var up_hit
var down_hit

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if up_hit or down_hit or is_colliding():
		hit.emit()
	else:
		no_hit.emit()

func _on_check_ru_hit():
	up_hit = true

func _on_check_ru_no_hit():
	up_hit = false

func _on_check_rd_hit():
	down_hit = true

func _on_check_rd_no_hit():
	down_hit = false
