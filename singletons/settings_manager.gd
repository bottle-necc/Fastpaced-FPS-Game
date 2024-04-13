extends Node

const SETTINGS_JSON_PATH = "user://settings.json"

var default_settings = {
	"controls" : {
		"sensitivity" : 0.0025,
		"sprint mode" : 1
	},
	"video" : {
		"fullscreen" : true
	},
	"keys" : {
		"general" : {
			"interact" : {
				"key" : "F",
				"mode" : 0
			},
			"scoreboard" : {
				"key" : "Tab",
				"mode" : 1
			},
			"taunt" : "B",
			"textchat" : "Enter",
			"voicechat" : {
				"key" : "CapsLock",
				"mode" : 0
			}
		},
		"movement" : {
			"forward" : "W",
			"backward" : "S",
			"left" : "A",
			"right" : "D",
			"sprint" : {
				"key" : "Shift",
				"mode" : 1
			},
			"crouch" : {
				"key" : "C",
				"mode" : 0
			},
			"prone" : {
				"key" : "Z",
				"mode" : 1
			},
			"crouch_prone" : {
				"key" : "X",
				"mode" : 0
			},
			"jump" : {
				"key" : "Space",
				"mode" : 1
			},
			"vault" : {
				"key" : "Alt",
				"mode" : 1
			},
			"jump_vault" : {
				"key" : "NONE",
				"mode" : 0
			}
		},
		"combat" : {
			"shoot" : 1,
			"aim" : {
				"key" : 2,
				"mode" : 0
			},
			"reload" : "R",
			"primary" : "1",
			"secondary" : "2",
			"grenade" : "G",
			"ability" : "Q",
			"tool" : "E",
			"melee" : {
				"key" : 3,
				"mode" : 0
			}
		}
	}
}

# Dictionary of the values in settings.json
var settings_dict = {}

# Used to transfer what action for the key listener to detect.
var action_int

func _ready():
	# Checks if the settings json file exists.
	var settings_exist = FileAccess.file_exists(SETTINGS_JSON_PATH)

	# If the file is missing, a new one will generate with default settings.
	if !settings_exist:
		var f = FileAccess.open("user://settings.json", FileAccess.WRITE)
		f.store_string(JSON.stringify(default_settings))
		f.close()

	load_settings()
	update_input_map()

func _process(delta):
	pass

func load_settings():
	var f = FileAccess.open("user://settings.json", FileAccess.READ)
	var json_string = f.get_as_text()
	f.close()
	settings_dict = JSON.parse_string(json_string)
	return settings_dict

func save_settings():
	var f = FileAccess.open("user://settings.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(settings_dict))
	f.close()

func update_input_map():
	var action_list = ["interact", "scoreboard", "taunt", "textchat", "voicechat", "forward", "backward", 
	"left", "right", "sprint", "crouch", "prone", "crouch_prone", "jump", "vault", "jump_vault", "shoot", 
	"aim", "reload", "primary", "secondary", "grenade", "ability", "tool", "melee"]

	var actions_without_mode = [2, 3, 5, 6, 7, 8, 16, 18, 19, 20, 21, 22, 23]
	var event
	var new_key

	# Iterates through the action list to remove all keybinds before reassigning them.
	for i in action_list:
		if Input.is_action_pressed(i):
			Input.action_release(i)
		InputMap.action_erase_events(i)

	for i in range(0, action_list.size()):
		var action_str = action_list[i]

		if i < 5:
			if i in actions_without_mode:
				new_key = settings_dict["keys"]["general"][action_str]
			else:
				new_key = settings_dict["keys"]["general"][action_str]["key"]
		elif i < 16:
			if i in actions_without_mode:
				new_key = settings_dict["keys"]["movement"][action_str]
			else:
				new_key = settings_dict["keys"]["movement"][action_str]["key"]
		else:
			if i in actions_without_mode:
				new_key = settings_dict["keys"]["combat"][action_str]
			else:
				new_key = settings_dict["keys"]["combat"][action_str]["key"]

		if new_key is String:
			new_key = OS.find_keycode_from_string(new_key)
			event = InputEventKey.new()
			event.set_physical_keycode(new_key)
			InputMap.action_add_event(action_str, event)
			continue

		else:
			event = InputEventMouseButton.new()
			event.button_index = new_key
			InputMap.action_add_event(action_str, event)
			continue
