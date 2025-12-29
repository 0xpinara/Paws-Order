extends Resource
class_name PlacedItemData
## PlacedItemData - An item placed in a room

@export var instance_id: int = 0  # Unique ID for this placed instance
@export var item_id: int = 0  # Reference to ItemData
@export var position: Vector2 = Vector2.ZERO
@export var rotation: float = 0.0
@export var flip_h: bool = false
@export var z_index: int = 0  # For layering
@export var contained_item: int = 0  # For containers (boxes, etc.)
@export var contained_amount: int = 0

