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

func _on_check_ruu_hit():
	up_hit = true
	
func _on_check_ruu_no_hit():
	up_hit = false

func _on_check_rud_hit():
	down_hit = true

func _on_check_rud_no_hit():
	down_hit = false
