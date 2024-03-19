extends Node

var action_list = ["interact", "scoreboard", "taunt", "textchat", "voicechat", "move forward", "move backward", 
"move left", "move right", "sprint", "crouch", "prone", "crouch/prone", "jump", "vault", "jump/vault", "shoot", 
"aim", "reload", "primary", "secondary", "grenade", "ability", "tool", "melee"]

# Called when the node enters the scene tree for the first time.
func _ready():
	print(SettingsManager.action_int)
	SettingsManager.action_int = null


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		queue_free()
