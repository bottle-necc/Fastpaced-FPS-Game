extends Node

signal unpause

@onready var pause_screen = $"Pause Screen"

func _ready():
	pause_screen.hide()
	unpause.emit()

func _on_player_paused():
	pause_screen.show()

func _on_button_pressed():
	pause_screen.hide()
	unpause.emit()

func _on_player_resumed():
	pause_screen.hide()
	unpause.emit()

func _on_quit_game_pressed():
	get_tree().quit()
