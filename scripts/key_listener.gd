extends Node

var action_list = ["interact", "scoreboard", "taunt", "textchat", "voicechat", "move forward", "move backward", 
"move left", "move right", "sprint", "crouch", "prone", "crouch/prone", "jump", "vault", "jump/vault", "shoot", 
"aim", "reload", "primary", "secondary", "grenade", "ability", "tool", "melee"]

# The purpose of this is to detect the move actions to properly capitalize them.
var move_list = ["Move forward", "Move backward", "Move left", "Move right"]

var mouse_list = ["MOUSE_BUTTON_NONE", "MOUSE_BUTTON_LEFT", "MOUSE_BUTTON_RIGHT", "MOUSE_BUTTON_MIDDLE", "MOUSE_BUTTON_WHEEL_UP",
"MOUSE_BUTTON_WHEEL_DOWN", "MOUSE_BUTTON_WHEEL_LEFT", "MOUSE_BUTTON_WHEEL_RIGHT", "MOUSE_BUTTON_XBUTTON1",
"MOUSE_BUTTON_XBUTTON2"]

@onready var action = $Panel/Action

var action_int
var new_key

func _unhandled_input(event):
	if event is InputEventKey:
		new_key = event.as_text_keycode()
		update_action_key()
		queue_free()

func _input(event):
	if event is InputEventMouseButton:
		new_key = mouse_list[event.button_index]
		update_action_key()
		queue_free()

# All of this is just to show which action the listener is editing.
func _ready():
	action_int = SettingsManager.action_int
	
	var label = action_list[action_int]
	label[0] = label[0].to_upper()

	if label in move_list:
		label[5] = label[5].to_upper()
	elif label == "Crouch/prone":
		label = "Crouch/Prone"
	elif label == "Jump/vault":
		label = "Jump/Vault"

	action.text = label
	action.anchor_left = 0.5
	action.anchor_right = 0.5
	action.anchor_top = 0.5
	action.anchor_bottom = 0.5

func update_action_key():
	var settings = SettingsManager.settings_dict
	var actions_without_mode = [2, 3, 5, 6, 7, 8, 16, 18, 19, 20, 21, 22, 23]
	var action_str = action_list[action_int]

	if new_key == "Delete":
		new_key = "NONE"

	if new_key == "Escape":
		queue_free()

	# Sets the new key for the action in the correct place.
	else:
		if action_int < 5:
			if action_int in actions_without_mode:
				settings["keys"]["general"][action_str] = new_key
			else:
				settings["keys"]["general"][action_str]["key"] = new_key
		elif action_int < 16:
			if action_int in actions_without_mode:
				settings["keys"]["movement"][action_str] = new_key
			else:
				settings["keys"]["movement"][action_str]["key"] = new_key
		else:
			if action_int in actions_without_mode:
				settings["keys"]["combat"][action_str] = new_key
			else:
				settings["keys"]["combat"][action_str]["key"] = new_key

	SettingsManager.save_settings()
	SettingsManager.update_input_map()
