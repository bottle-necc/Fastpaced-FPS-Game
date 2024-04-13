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
			"move forward" : "W",
			"move backward" : "S",
			"move left" : "A",
			"move right" : "D",
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
			"crouch/prone" : {
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
			"jump/vault" : {
				"key" : "NONE",
				"mode" : 0
			}
		},
		"combat" : {
			"shoot" : "MOUSE_BUTTON_LEFT",
			"aim" : {
				"key" : "MOUSE_BUTTON_RIGHT",
				"mode" : 0
			},
			"reload" : "R",
			"primary" : "1",
			"secondary" : "2",
			"grenade" : "G",
			"ability" : "Q",
			"tool" : "E",
			"melee" : {
				"key" : "MOUSE_BUTTON_MIDDLE",
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
	"left", "right", "sprint", "crouch", "prone", "crouch/prone", "jump", "vault", "jump/vault", "shoot", 
	"aim", "reload", "primary", "secondary", "grenade", "ability", "tool", "melee"]
	var event

	# Iterates through the action list to remove all keybinds before reassigning them.
	for i in action_list:
		if Input.is_action_pressed(i):
			Input.action_release(i)
		InputMap.action_erase_events(i)

# I FOUND IT, I CAN CHANGE THE INPUTMAP THROUGH JSON WITH THIS!!!!!!!
		#event = InputEventKey.new()
		#event.keycode = KEY_R
		#InputMap.action_add_event("forward", event)
