extends RayCast3D

signal hit
signal no_hit

func _process(delta):
	if is_colliding():
		hit.emit()
	else:
		no_hit.emit()
