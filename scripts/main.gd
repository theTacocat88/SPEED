extends Control

var player: Dictionary = {}

# INFO: Character Creation @onready
@onready var char_creation_popup_1: PopupPanel = $CharCreation
@onready var char_creation_popup_warrior: PopupPanel = $WarriorWeaponsSelection
@onready var char_creation_popup_mage: PopupPanel = $MageWeaponsSelection
@onready var char_creation_popup_barbarian: PopupPanel = $BarbarianWeaponsSelection

# INFO: Input for char_creation_popup_1
@onready var name_input: LineEdit = $CharCreation/Layout/NameInput
@onready var base_select: OptionButton = $CharCreation/Layout/BaseSelect

# INFO: Variables for SkillPointAllocation
@onready var skill_point_allocation: PopupPanel = $SkillPointAllocation
@onready var sp_label: Label = $SkillPointAllocation/SkillPoints/SPLabel
@onready var skill_grid: GridContainer = $SkillPointAllocation/SkillPoints/SkillGrid

# INFO: base_select.selected = 0 sets to WARRIOR
func _ready() -> void:
	base_select.selected = 0

# NOTE: Quit button
func _on_quit_pressed() -> void:
	save()
	get_tree().quit(0)

# NOTE: New Game button
func _on_new_game_pressed() -> void:
	char_creation_popup_1.popup_centered()

# NOTE: Continue in first char_creation popup
func _on_continue_cswp_pressed() -> void:
	var cname: String = name_input.text.strip_edges()
	if cname == "":
		return
	player["name"] = cname
	player["base"] = base_select.get_item_text(base_select.selected)
	match player["base"]:
		"Warrior":
			_set_warrior()
		"Mage":
			_set_mage()
		"Barbarian":
			_set_barbarian()
	player["level"] = 0
	player["weapons"] = []
	player["equipped_weapon"] = ""
	
	# CRITICAL: USE SAVE TO SAVE player TO save.json
	save()
	weapon_window()

# NOTE: set player to warrior
func _set_warrior() -> void:
	player["max_health"] = 100; player["health"] = 100
	player["dex"] = 3; player["str"] = 3; player["vit"] = 2
	player["int"] = 1; player["wis"] = 0; player["cha"] = 2
	player["mgc"] = 0
	player["sp"] = 3; player["spl"] = 1

# NOTE: set player to mage
func _set_mage() -> void:
	player["max_health"] = 90; player["health"] = 90
	player["dex"] = 4; player["str"] = 1; player["vit"] = 3
	player["int"] = 4; player["wis"] = 3; player["cha"] = 0
	player["mgc"] = 5
	player["gmgc"] = 100; player["mgcr"] = 5
	player["sp"] = 2; player["spl"] = 1

# NOTE: set player to barbarian
func _set_barbarian() -> void:
	player["max_health"] = 110; player["health"] = 110
	player["dex"] = 1; player["str"] = 5; player["vit"] = 2
	player["int"] = 0; player["wis"] = 0; player["cha"] = 1
	player["mgc"] = 0
	player["sp"] = 5; player["spl"] = 1

# NOTE: Get the current stat list for the player's base
func _get_stat_list_for_base() -> Array:
	match player["base"]:
		"Warrior":
			return ["max_health","health","dex","str","vit","int","wis","cha","mgc","spl"]
		"Mage":
			return ["max_health","health","dex","str","vit","int","wis","cha","mgc","spl","gmgc","mgcr"]
		"Barbarian":
			return ["max_health","health","dex","str","vit","int","wis","cha","mgc","spl"]
		_:
			return []

# NOTE: Cancel in first char_creation popup
func _on_cancel_charcc_pressed() -> void:
	char_creation_popup_1.hide()

# INFO: Weapon selction window
func weapon_window():
	char_creation_popup_1.hide()
	match player["base"]:
		"Warrior":
			char_creation_popup_warrior.popup_centered()
		"Mage":
			char_creation_popup_mage.popup_centered()
		"Barbarian":
			char_creation_popup_barbarian.popup_centered()

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

# NOTE: Select button in weapon selection
func _on_select_pressed(weapon: String) -> void:
	player["equipped_weapon"] = weapon
	player["weapons"].append(weapon)
	save()
	match player["base"]:
		"Warrior":
			char_creation_popup_warrior.hide()
		"Mage":
			char_creation_popup_mage.hide()
		"Barbarian":
			char_creation_popup_barbarian.hide()
	
	allocate_skills()

# NOTE: Done button in Stat Allocation
func _on_done_stat_pressed() -> void:
	skill_point_allocation.hide()
	get_tree().change_scene_to_file("res://scenes/game_menu.tscn")

# INFO: Shows skill point allocation screen
func allocate_skills():
	for child in skill_grid.get_children():
		child.queue_free()
	
	var stats = _get_stat_list_for_base()
	for stat in stats:
		var current = player.get(stat, 0)
		var label = Label.new()
		label.text = "%s: %d" % [stat, current]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		skill_grid.add_child(label)
		
		var button = Button.new()
		button.text = "+"
		button.disabled = (player['sp'] <= 0)
		button.pressed.connect(func():
			if player['sp'] <= 0:
				return
			player['sp'] -= 1
			
			match stat:
				"max_health", "health", "mgc", "mgcr", "spl":
					player[stat] += 5
				"gmgc":
					player[stat] += 10
				_:
					player[stat] += 1
			if stat == "max_health":
				player["health"] = min(player["health"], player["max_health"])
			label.text = "%s: %d" % [stat, player[stat]]
			_update_sp_label()
			_update_all_plus_buttons()
			save()
		)
		skill_grid.add_child(button)
	
	_update_sp_label()
	_update_all_plus_buttons()
	skill_point_allocation.popup_centered()

func _update_sp_label() -> void:
	sp_label.text = "Skill Points: %d" % player["sp"]

func _update_all_plus_buttons() -> void:
	var enabled = player['sp'] > 0
	for i in range(1, skill_grid.get_child_count(), 2):  # INFO: every 2nd child = button
		var btn = skill_grid.get_child(i) as Button
		if btn:
			btn.disabled = !enabled

func _on_delete_save_pressed() -> void:
	var file_path = "user://save.json"
	if DirAccess.remove_absolute(file_path) == OK:
		return
	else:
		return


func _on_load_game_pressed() -> void:
	loads()
	get_tree().change_scene_to_file("res://scenes/game_menu.tscn")
