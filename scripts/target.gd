extends CharacterBody3D

signal hit

var health = 100

# Target dies if health is depleted.
func _physics_process(delta):
	if health <= 0:
		queue_free()

func _on_hit():
	health -= 25
