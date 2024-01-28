extends Node3D

const speed = 900

@onready var ray = $RayCast3D

# Moves the bullet forward.
func _process(delta):
	position += transform.basis * Vector3(0, 0, -speed) * delta
	if ray.is_colliding():
		# If the bullet hits a player than it will hurt them.
		if ray.get_collider().is_in_group("Players"):
			ray.get_collider().hit.emit()
		queue_free()

func _on_despawn_timer_timeout():
	queue_free()
