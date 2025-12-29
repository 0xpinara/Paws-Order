extends Node
## SaveManager - Handles saving and loading game data
## Uses JSON for human-readable save files

const SAVE_PATH = "user://pet_society_save.json"

signal save_completed()
signal load_completed()
signal save_error(message: String)


func _ready() -> void:
	print("[SaveManager] Initialized")


## Save all game data to file
func save_game() -> void:
	var save_data = {
		"version": 2,
		"timestamp": Time.get_unix_time_from_system(),
		"coins": GameManager.coins,
		"cash": GameManager.cash,
		"has_pet": GameManager.has_pet,
		"current_room": GameManager.current_room_index,
		"owned_rooms": GameManager.owned_rooms,
		"inventory": GameManager.inventory,
		"room_furniture": GameManager.room_furniture,
		"next_furniture_id": GameManager.next_furniture_id,
	}
	
	# Save pet data if exists
	if GameManager.pet_data != null:
		save_data["pet"] = {
			"name": GameManager.pet_data.name,
			"primary_color": GameManager.pet_data.primary_color.to_html(),
			"features": GameManager.pet_data.features,
			"birthday": GameManager.pet_data.birthday,
			"health": GameManager.pet_data.health,
			"happiness": GameManager.pet_data.happiness,
			"hygiene": GameManager.pet_data.hygiene,
			"level": GameManager.pet_data.level,
			"experience": GameManager.pet_data.experience,
		}
	
	var json_string = JSON.stringify(save_data, "\t")
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		var error = FileAccess.get_open_error()
		push_error("[SaveManager] Failed to open save file: " + str(error))
		save_error.emit("Failed to save game")
		return
	
	file.store_string(json_string)
	file.close()
	
	save_completed.emit()
	print("[SaveManager] Game saved successfully")


## Load game data from file
func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		print("[SaveManager] No save file found")
		return false
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("[SaveManager] Failed to open save file for reading")
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("[SaveManager] Failed to parse save file: " + json.get_error_message())
		return false
	
	var save_data = json.get_data()
	
	# Validate save version
	if not save_data.has("version"):
		push_error("[SaveManager] Invalid save file format")
		return false
	
	# Load basic data
	GameManager.coins = save_data.get("coins", 500)
	GameManager.cash = save_data.get("cash", 0)
	GameManager.has_pet = save_data.get("has_pet", false)
	GameManager.current_room_index = save_data.get("current_room", 0)
	GameManager.owned_rooms = save_data.get("owned_rooms", [0])
	GameManager.inventory = save_data.get("inventory", [])
	GameManager.room_furniture = save_data.get("room_furniture", {})
	GameManager.next_furniture_id = save_data.get("next_furniture_id", 1)
	
	# Load pet data
	if save_data.has("pet"):
		var pet_save = save_data["pet"]
		GameManager.pet_data = PetData.new()
		GameManager.pet_data.name = pet_save.get("name", "Pet")
		GameManager.pet_data.primary_color = Color.html(pet_save.get("primary_color", "#FFFFFF"))
		GameManager.pet_data.features = pet_save.get("features", {})
		GameManager.pet_data.birthday = pet_save.get("birthday", 0)
		GameManager.pet_data.health = pet_save.get("health", 100)
		GameManager.pet_data.happiness = pet_save.get("happiness", 100)
		GameManager.pet_data.hygiene = pet_save.get("hygiene", 100)
		GameManager.pet_data.level = pet_save.get("level", 1)
		GameManager.pet_data.experience = pet_save.get("experience", 0)
	
	load_completed.emit()
	print("[SaveManager] Game loaded successfully")
	return true


## Check if a save file exists
func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


## Delete save file
func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print("[SaveManager] Save file deleted")

