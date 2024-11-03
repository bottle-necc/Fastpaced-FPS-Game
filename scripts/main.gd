extends Node

@export var enemy: PackedScene

func _on_spawn_enemy_pressed():
	var new_enemy = enemy.instantiate()
	new_enemy.position.y = 1
	new_enemy.position.z = -15
	add_child(new_enemy)
