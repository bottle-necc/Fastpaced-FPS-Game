extends Node

const SETTINGS_JSON_PATH = "user://settings.json"

var default_settings = {
	"controls" : {
		"sensitivity" : 0.0025
	},
	"video" : {
		"fullscreen" : true
	}
}

# Dictionary of the values in settings.json
var settings_dict = {}

var json = JSON.new()

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

	# Don't ask me why I need an initialized json funtion here but not while saving. I've got no clue.
	# Also since the code works... I don't care.
	settings_dict = json.parse_string(json_string)
	return settings_dict

func save_settings():
	var f = FileAccess.open("user://settings.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(settings_dict))
	f.close()

	# After saving, the new settings will be loaded to ensure everything is up to date.
	load_settings()
