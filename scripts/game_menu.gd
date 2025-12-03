extends Control

var player: Dictionary = {}

@onready var name_label: Label = $Menu/Name

func _ready() -> void:
	loads()
	name_label.text = player["name"]

# CRITICAL: USE FOR SAVING TO save.json
func save():
	var filepath: String = "user://save.json"
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	if file == null:
		print("Save failed -> user://")
	var json_str = JSON.stringify(player)
	file.store_string(json_str)
	file.close()

# CRITICAL: USE FOR LOADING FROM save.json
func loads():
	var filepath: String = "user://save.json"
	if FileAccess.file_exists(filepath):
		var file = FileAccess.open(filepath, FileAccess.READ)
		var json_str: String = file.get_as_text()
		player = JSON.parse_string(json_str)
		file.close()
