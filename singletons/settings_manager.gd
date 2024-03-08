extends Node

const SETTINGS_JSON_PATH = "user://settings.json"

var default_settings = {
	"controls" : {
		"sensitivity" : 0.0025,
		}
}

# Dictionary of the values in settings.json
var settings_dict = {}

var json = JSON.new()

func _ready():
	var settings_exist = FileAccess.file_exists(SETTINGS_JSON_PATH)

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
	settings_dict = json.parse_string(json_string)
	return settings_dict

func save_settings():
	var f = FileAccess.open("user://settings.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(settings_dict))
	f.close
