extends Control

var player: Dictionary = {}

@onready var char_creation_popup_1: PopupPanel = $CharCreation
@onready var char_creation_popup_warrior: PopupPanel = $WarriorWeaponsSelection
@onready var char_creation_popup_mage: PopupPanel = $MageWeaponsSelection
@onready var char_creation_popup_barbarian: PopupPanel = $BarbarianWeaponsSelection
@onready var name_input: LineEdit = $CharCreation/Layout/NameInput
@onready var base_select: OptionButton = $CharCreation/Layout/BaseSelect

func _ready() -> void:
	base_select.selected = 0

func _on_quit_pressed() -> void:
	get_tree().quit(0)

func _on_new_game_pressed() -> void:
	char_creation_popup_1.popup_centered()

func _on_continue_cswp_pressed() -> void:
	var cname: String = name_input.text.strip_edges()
	if cname == "":
		return
	player["name"] = cname
	player["base"] = base_select.get_item_text(base_select.selected)
	match player["base"]:
		"Warrior":
			player["max_health"] = 100
			player["health"] = 100
			player["dex"] = 3
			player["str"] = 3
			player["vit"] = 2
			player["int"] = 1
			player["wis"] = 0
			player["cha"] = 2
			player["mgc"] = 0
			player["sp"] = 3
			player["spl"] = 1
		"Mage":
			player["max_health"] = 90
			player["health"] = 90
			player["dex"] = 4
			player["str"] = 1
			player["vit"] = 3
			player["int"] = 4
			player["wis"] = 3
			player["cha"] = 0
			player["mgc"] = 5
			player["gmgc"] = 100
			player["mgcr"] = 5
			player["sp"] = 2
			player["spl"] = 1
		"Barbarian":
			player["max_health"] = 110
			player["health"] = 110
			player["dex"] = 1
			player["str"] = 5
			player["vit"] = 2
			player["int"] = 0
			player["wis"] = 0
			player["cha"] = 1
			player["mgc"] = 0
			player["sp"] = 5
			player["spl"] = 1
	player["level"] = 0
	
	save()
	weapon_window()
	#get_tree().change_scene_to_file("res://Game.tscn")

func _on_cancel_charcc_pressed() -> void:
	char_creation_popup_1.hide()

func weapon_window():
	char_creation_popup_1.hide()
	match player["base"]:
		"Warrior":
			char_creation_popup_warrior.popup_centered()
		"Mage":
			char_creation_popup_mage.popup_centered()
		"Barbarian":
			char_creation_popup_barbarian.popup_centered()

func save():
	var filepath: String = "user://save.json" % player["name"].to_lower().replace(" ", "_")
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	if file == null:
		print("Save failed -> user://")
	var json_str = JSON.stringify(player)
	file.store_string(json_str)
	file.close()


func _on_select_pressed(weapon: String) -> void:
	player["equipped_weapon"] = weapon
	player["weapons"].append(weapon)
