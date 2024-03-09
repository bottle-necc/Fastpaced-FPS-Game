extends Node

const SETTINGS_JSON_PATH = "user://settings.json"

var default_settings = {
	"controls" : {
		"sensitivity" : 0.0025,
		"sprint mode" : 0
	},
	"video" : {
		"fullscreen" : true
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
