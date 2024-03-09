extends Node

signal unpause

var is_paused = false
var child_list

@onready var pause_screen = $"Pause Screen"
@onready var options_screen = $"Options Screen"
@onready var background = $Background
@onready var video = $"Options Screen/Video"
@onready var controls = $"Options Screen/Controls"
@onready var audio = $"Options Screen/Audio"
@onready var sensitivity = $"Options Screen/Controls/Sensitivity"
@onready var keys = $"Options Screen/Key Mapping"
@onready var fullscreen = $"Options Screen/Video/Fullscreen"

func _ready():
	var settings = SettingsManager.settings_dict
	pause_screen.hide()
	options_screen.hide()
	unpause.emit()

	# Adjusts the slider position to reflect the current mouse sensitivity
	sensitivity.value = settings["controls"]["sensitivity"] * 10000

	# Toggles to fullscreen/windowed on bootup, depending on user input
	fullscreen.button_pressed = settings["video"]["fullscreen"]
	_on_fullscreen_pressed()

	# Shows the current sprint mode on bootup
	$"Options Screen/Controls/Sprint Mode".selected = settings["controls"]["sprint mode"]

	# Shows a default tab on start-up
	child_list = video.get_children()
	for i in child_list:
		i.show()

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

func swap_tab(tab):
	# Hides all the children of the previous tab before giving a new array to child_list.
	if child_list != tab.get_children():
		for i in child_list:
			i.hide()

		child_list = tab.get_children()

	# Shows all of the children of the current tab once the new array has been assigned to child_list.
	for i in child_list:
		i.show()

func _on_controls_pressed():
	swap_tab(controls)

func _on_sensitivity_value_changed(value):
	var settings = SettingsManager.settings_dict
	settings["controls"]["sensitivity"] = value * 0.0001
	SettingsManager.save_settings()

func _on_video_pressed():
	swap_tab(video)

func _on_audio_pressed():
	swap_tab(audio)

func _on_key_mapping_pressed():
	swap_tab(keys)

func _on_fullscreen_pressed():
	var is_fullscreen = fullscreen.button_pressed
	var settings = SettingsManager.settings_dict

	# Adjusts between fullscreen and windowed depending on the setting.
	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	# Saves the current setting.
	settings["video"]["fullscreen"] = is_fullscreen
	SettingsManager.save_settings()

func _on_sprint_mode_item_selected(index):
	var settings = SettingsManager.settings_dict
	settings["controls"]["sprint mode"] = index
	SettingsManager.save_settings()
