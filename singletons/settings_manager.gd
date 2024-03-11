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
				"key" : "f",
				"mode" : 0
			},
			"scoreboard" : {
				"key" : "tab",
				"mode" : 1
			},
			"tuant" : "b",
			"textchat" : "enter",
			"voicechat" : {
				"key" : "caps",
				"mode" : 0
			}
		},
		"movement" : {
			"move forward" : "w",
			"move backward" : "s",
			"move left" : "a",
			"move right" : "d",
			"sprint" : {
				"key" : "shift",
				"mode" : 1
			},
			"crouch" : {
				"key" : "c",
				"mode" : 0
			},
			"prone" : {
				"key" : "z",
				"mode" : 1
			},
			"crouch/prone" : {
				"key" : "x",
				"mode" : 0
			},
			"jump" : {
				"key" : "space",
				"mode" : 1
			},
			"vault" : {
				"key" : "lalt",
				"mode" : 1
			},
			"jump/vault" : {
				"key" : "NONE",
				"mode" : 0
			}
		},
		"combat" : {
			"shoot" : "lmb",
			"aim" : {
				"key" : "rmb",
				"mode" : 0
			},
			"reload" : "r",
			"primary" : "1",
			"secondary" : "2",
			"grenade" : "g",
			"ability" : "q",
			"tool" : "e",
			"melee" : {
				"key" : "mmb",
				"mode" : 0
			}
		}
	}
}

# Dictionary of the values in settings.json
var settings_dict = {}

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

	# After saving, the new settings will be loaded to ensure everything is up to date.
	load_settings()
