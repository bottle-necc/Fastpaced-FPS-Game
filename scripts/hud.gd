extends Node

signal unpause

var is_paused = false

@onready var pause_screen = $"Pause Screen"
@onready var options_screen = $"Options Screen"
@onready var background = $Background

func _ready():
	pause_screen.hide()
	options_screen.hide()
	unpause.emit()

func _process(delta):
	background.global_position.x = 0
	background.global_position.y = 0
	background.size.x = get_window().size.x
	background.size.y = get_window().size.y

	if is_paused:
		background.show()
	else:
		background.hide()

func _on_player_paused():
	if !is_paused:
		pause_screen.show()
		is_paused = true

func _on_button_pressed():
	pause_screen.hide()
	unpause.emit()
	is_paused = false

func _on_quit_game_pressed():
	get_tree().quit()

func _on_options_pressed():
	options_screen.show()
	pause_screen.hide()

func _on_return_pressed():
	options_screen.hide()
	pause_screen.show()
