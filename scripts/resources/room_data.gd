extends Resource
class_name RoomData
## RoomData - Stores information about a room

@export var room_index: int = 0
@export var room_name: String = "Room"
@export var room_type: RoomType = RoomType.INDOOR
@export var width: int = 800
@export var height: int = 600
@export var wallpaper_id: int = 0
@export var floor_id: int = 0
@export var placed_items: Array[PlacedItemData] = []

enum RoomType { INDOOR, GARDEN, SPECIAL }


## Add an item to the room
func add_item(item_id: int, position: Vector2, rotation: float = 0.0) -> PlacedItemData:
	var placed = PlacedItemData.new()
	placed.item_id = item_id
	placed.position = position
	placed.rotation = rotation
	placed.instance_id = _generate_instance_id()
	placed_items.append(placed)
	return placed


## Remove an item from the room
func remove_item(instance_id: int) -> bool:
	for i in range(placed_items.size()):
		if placed_items[i].instance_id == instance_id:
			placed_items.remove_at(i)
			return true
	return false


## Move an item
func move_item(instance_id: int, new_position: Vector2) -> bool:
	for item in placed_items:
		if item.instance_id == instance_id:
			item.position = new_position
			return true
	return false


## Generate unique instance ID
func _generate_instance_id() -> int:
	var max_id = 0
	for item in placed_items:
		if item.instance_id > max_id:
			max_id = item.instance_id
	return max_id + 1


