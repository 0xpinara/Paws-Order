extends Node
## GameManager - Central game state controller
## Handles pet data, coins, and game state transitions

# Signals for game state changes
signal coins_changed(new_amount: int)
signal cash_changed(new_amount: int)
signal pet_stats_changed()
signal pet_created()
signal room_changed(room_index: int)

# Player Resources
var coins: int = 500:
	set(value):
		coins = max(0, value)
		coins_changed.emit(coins)

var cash: int = 0:  # Premium currency
	set(value):
		cash = max(0, value)
		cash_changed.emit(cash)

# Pet Data
var pet_data: PetData = null
var has_pet: bool = false

# Room Data
var current_room_index: int = 0
var owned_rooms: Array[int] = [0]  # Start with main room
var room_furniture: Dictionary = {}  # room_index -> Array of placed furniture

# Inventory - Array of item IDs
var inventory: Array[int] = []

# Placed furniture tracking
var next_furniture_id: int = 1

# Game State
enum GameState { MENU, PET_CREATOR, HOME, SHOP, VISITING, MINIGAME }
var current_state: GameState = GameState.MENU


func _ready() -> void:
	print("[GameManager] Initialized")


## Creates a new pet with the given data
func create_pet(name: String, color: Color, features: Dictionary) -> void:
	pet_data = PetData.new()
	pet_data.name = name
	pet_data.primary_color = color
	pet_data.features = features
	pet_data.birthday = Time.get_unix_time_from_system()
	pet_data.health = 100
	pet_data.happiness = 100
	pet_data.hygiene = 100
	pet_data.level = 1
	pet_data.experience = 0
	
	has_pet = true
	pet_created.emit()
	
	# Give starter items
	_give_starter_items()
	
	# Save immediately
	SaveManager.save_game()
	
	print("[GameManager] Pet created: ", name)


## Give new players some starter items
func _give_starter_items() -> void:
	# TODO: Add starter furniture and food items
	coins = 500


## Update pet stats over time (called from game loop)
func update_pet_stats(delta: float) -> void:
	if pet_data == null:
		return
	
	# Stats decay over time (very slowly)
	var decay_rate = 0.01 * delta  # 1% per 100 seconds
	
	pet_data.health = max(0, pet_data.health - decay_rate * 0.5)
	pet_data.happiness = max(0, pet_data.happiness - decay_rate)
	pet_data.hygiene = max(0, pet_data.hygiene - decay_rate * 0.3)
	
	pet_stats_changed.emit()


## Feed the pet
func feed_pet(food_value: int) -> void:
	if pet_data == null:
		return
	
	pet_data.health = min(100, pet_data.health + food_value)
	pet_data.happiness = min(100, pet_data.happiness + food_value * 0.5)
	pet_stats_changed.emit()
	SaveManager.save_game()


## Wash the pet
func wash_pet(hygiene_value: int) -> void:
	if pet_data == null:
		return
	
	pet_data.hygiene = min(100, pet_data.hygiene + hygiene_value)
	pet_data.happiness = min(100, pet_data.happiness + hygiene_value * 0.3)
	pet_stats_changed.emit()
	SaveManager.save_game()


## Play with the pet
func play_with_pet(happiness_value: int) -> void:
	if pet_data == null:
		return
	
	pet_data.happiness = min(100, pet_data.happiness + happiness_value)
	pet_data.hygiene = max(0, pet_data.hygiene - happiness_value * 0.1)
	pet_stats_changed.emit()
	SaveManager.save_game()


## Add coins
func add_coins(amount: int) -> void:
	coins += amount
	SaveManager.save_game()


## Spend coins - returns true if successful
func spend_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		SaveManager.save_game()
		return true
	return false


## Add item to inventory
func add_item(item_id: int) -> void:
	inventory.append(item_id)
	SaveManager.save_game()


## Remove item from inventory
func remove_item(item_id: int) -> bool:
	var index = inventory.find(item_id)
	if index != -1:
		inventory.remove_at(index)
		SaveManager.save_game()
		return true
	return false


## Change current room
func change_room(room_index: int) -> void:
	if room_index in owned_rooms:
		current_room_index = room_index
		room_changed.emit(room_index)


## Place furniture in current room
func place_furniture(item_id: int, position: Vector2) -> Dictionary:
	# Remove from inventory
	if not remove_item(item_id):
		return {}
	
	# Get or create room furniture array
	if not room_furniture.has(current_room_index):
		room_furniture[current_room_index] = []
	
	# Create placed furniture data
	var furniture = {
		"id": next_furniture_id,
		"item_id": item_id,
		"position_x": position.x,
		"position_y": position.y,
		"rotation": 0.0,
		"flip_h": false
	}
	
	next_furniture_id += 1
	room_furniture[current_room_index].append(furniture)
	SaveManager.save_game()
	
	return furniture


## Move furniture in room
func move_furniture(furniture_id: int, new_position: Vector2) -> bool:
	if not room_furniture.has(current_room_index):
		return false
	
	for furniture in room_furniture[current_room_index]:
		if furniture["id"] == furniture_id:
			furniture["position_x"] = new_position.x
			furniture["position_y"] = new_position.y
			SaveManager.save_game()
			return true
	
	return false


## Pick up furniture (return to inventory)
func pickup_furniture(furniture_id: int) -> bool:
	if not room_furniture.has(current_room_index):
		return false
	
	for i in range(room_furniture[current_room_index].size()):
		var furniture = room_furniture[current_room_index][i]
		if furniture["id"] == furniture_id:
			# Add back to inventory
			add_item(furniture["item_id"])
			# Remove from room
			room_furniture[current_room_index].remove_at(i)
			SaveManager.save_game()
			return true
	
	return false


## Get furniture in current room
func get_room_furniture() -> Array:
	if room_furniture.has(current_room_index):
		return room_furniture[current_room_index]
	return []


## Reset game (for testing)
func reset_game() -> void:
	pet_data = null
	has_pet = false
	coins = 500
	cash = 0
	current_room_index = 0
	owned_rooms = [0]
	inventory = []
	room_furniture = {}
	next_furniture_id = 1
	current_state = GameState.MENU
	SaveManager.delete_save()
	print("[GameManager] Game reset")


