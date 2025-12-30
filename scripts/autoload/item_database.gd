extends Node
## ItemDatabase - Stores all item definitions
## Loaded from data files at startup

# Item categories
enum ItemCategory {
	FURNITURE,
	WALLPAPER,
	FLOOR,
	CLOTHING_HAT,
	CLOTHING_SHIRT,
	CLOTHING_PANTS,
	CLOTHING_SHOES,
	CLOTHING_ACCESSORY,
	FOOD,
	TOY,
	DECORATION,
	PLANT,
	PET_ACCESSORY,
	SPECIAL
}

# Item data storage
var items: Dictionary = {}  # item_hash -> ItemData
var items_by_category: Dictionary = {}  # category -> Array[ItemData]


func _ready() -> void:
	_init_categories()
	_load_items()
	print("[ItemDatabase] Initialized with ", items.size(), " items")


func _init_categories() -> void:
	for category in ItemCategory.values():
		items_by_category[category] = []


## Load items from data files
func _load_items() -> void:
	# TODO: Load from XML/JSON data files
	# For now, create some test items
	_create_test_items()


## Create test items for development
func _create_test_items() -> void:
	# Food items
	_add_item(1001, "Apple", ItemCategory.FOOD, 10, "A fresh red apple", 15)
	_add_item(1002, "Bread", ItemCategory.FOOD, 15, "Freshly baked bread", 20)
	_add_item(1003, "Cookie", ItemCategory.FOOD, 20, "A delicious cookie", 25)
	_add_item(1004, "Cake", ItemCategory.FOOD, 50, "A birthday cake", 40)
	_add_item(1005, "Fish", ItemCategory.FOOD, 30, "Fresh fish", 35)
	
	# Furniture
	_add_item(2001, "Wooden Chair", ItemCategory.FURNITURE, 100, "A simple wooden chair", 0)
	_add_item(2002, "Wooden Table", ItemCategory.FURNITURE, 150, "A sturdy wooden table", 0)
	_add_item(2003, "Cozy Sofa", ItemCategory.FURNITURE, 300, "A comfortable sofa", 0)
	_add_item(2004, "Bookshelf", ItemCategory.FURNITURE, 200, "Store your books here", 0)
	_add_item(2005, "Lamp", ItemCategory.FURNITURE, 80, "A warm lamp", 0)
	_add_item(2006, "Bed", ItemCategory.FURNITURE, 400, "A cozy bed for your pet", 0)
	_add_item(2007, "Rug", ItemCategory.FURNITURE, 120, "A soft rug", 0)
	_add_item(2008, "Plant Pot", ItemCategory.FURNITURE, 50, "A decorative plant", 0)
	
	# Decorations
	_add_item(3001, "Painting", ItemCategory.DECORATION, 150, "A beautiful painting", 0)
	_add_item(3002, "Clock", ItemCategory.DECORATION, 80, "Tells the time", 0)
	_add_item(3003, "Mirror", ItemCategory.DECORATION, 100, "See your reflection", 0)
	_add_item(3004, "Vase", ItemCategory.DECORATION, 60, "A pretty vase", 0)
	
	# Toys
	_add_item(4001, "Ball", ItemCategory.TOY, 30, "A bouncy ball", 0)
	_add_item(4002, "Frisbee", ItemCategory.TOY, 40, "Throw and catch", 0)
	_add_item(4003, "Jump Rope", ItemCategory.TOY, 35, "For jumping games", 0)
	
	# Clothing
	_add_item(5001, "Red Hat", ItemCategory.CLOTHING_HAT, 50, "A stylish red hat", 0)
	_add_item(5002, "Blue Shirt", ItemCategory.CLOTHING_SHIRT, 60, "A cool blue shirt", 0)
	_add_item(5003, "Green Pants", ItemCategory.CLOTHING_PANTS, 55, "Comfy green pants", 0)


## Helper to add item to database
func _add_item(id: int, name: String, category: ItemCategory, price: int, description: String, food_value: int = 0) -> void:
	var item = ItemData.new()
	item.id = id
	item.name = name
	item.category = category
	item.price = price
	item.description = description
	item.food_value = food_value
	
	items[id] = item
	items_by_category[category].append(item)


## Get item by ID
func get_item(item_id: int) -> ItemData:
	return items.get(item_id, null)


## Get all items in a category
func get_items_by_category(category: ItemCategory) -> Array:
	return items_by_category.get(category, [])


## Get all food items
func get_food_items() -> Array:
	return items_by_category.get(ItemCategory.FOOD, [])


## Get all furniture items
func get_furniture_items() -> Array:
	return items_by_category.get(ItemCategory.FURNITURE, [])


## Search items by name
func search_items(query: String) -> Array:
	var results = []
	var lower_query = query.to_lower()
	
	for item in items.values():
		if item.name.to_lower().contains(lower_query):
			results.append(item)
	
	return results


