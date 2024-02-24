extends Node

const SETTINGS_JSON_PATH = "user://settings.json"

var default_settings = {
	"controls" : {
		"sensitivity" : 0.0025
	}
}

func _ready():
	var json = JSON.new()
	var settings_exist = FileAccess.file_exists(SETTINGS_JSON_PATH)

	if !settings_exist:
		var f = FileAccess.open("user://settings.json", FileAccess.WRITE)
		f.store_string(json.stringify(default_settings))
		f.close()

func _process(delta):
	pass
