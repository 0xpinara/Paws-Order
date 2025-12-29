extends Resource
class_name ItemData
## ItemData - Stores information about an item

@export var id: int = 0
@export var name: String = ""
@export var description: String = ""
@export var category: int = 0  # ItemDatabase.ItemCategory
@export var price: int = 0
@export var sell_price: int = 0  # Auto-calculated as price / 2
@export var item_hash: int = 0  # Original game hash for asset lookup
@export var food_value: int = 0  # How much health it restores (for food)
@export var happiness_value: int = 0  # How much happiness it gives (for toys)
@export var is_buyable: bool = true
@export var is_tradeable: bool = true
@export var required_level: int = 1
@export var sprite_path: String = ""


func _init() -> void:
	sell_price = price / 2


## Check if player can afford this item
func can_afford(coins: int) -> bool:
	return coins >= price


## Check if player meets level requirement
func meets_level_requirement(player_level: int) -> bool:
	return player_level >= required_level


## Get category name as string
func get_category_name() -> String:
	match category:
		0: return "Furniture"
		1: return "Wallpaper"
		2: return "Floor"
		3: return "Hat"
		4: return "Shirt"
		5: return "Pants"
		6: return "Shoes"
		7: return "Accessory"
		8: return "Food"
		9: return "Toy"
		10: return "Decoration"
		11: return "Plant"
		12: return "Pet Accessory"
		13: return "Special"
	return "Unknown"

