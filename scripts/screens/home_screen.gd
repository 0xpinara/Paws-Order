extends Control
## HomeScreen - Main gameplay screen where pet lives

# UI References
@onready var pet_name_label: Label = $TopBar/HBox/PetName
@onready var coin_label: Label = $TopBar/HBox/CoinLabel
@onready var health_bar: ProgressBar = $StatsPanel/VBox/HealthBar
@onready var happy_bar: ProgressBar = $StatsPanel/VBox/HappyBar
@onready var hygiene_bar: ProgressBar = $StatsPanel/VBox/HygieneBar
@onready var furniture_container: Node2D = $RoomLayer/FurnitureContainer
@onready var pet_container: Node2D = $RoomLayer/PetContainer

# Pet visual
var pet_sprite: Node2D = null

# Edit mode for furniture placement
var edit_mode: bool = false
var dragging_item: Node2D = null
var drag_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	# Connect signals
	GameManager.coins_changed.connect(_on_coins_changed)
	GameManager.pet_stats_changed.connect(_on_stats_changed)
	
	# Initial UI update
	_update_ui()
	
	# Create pet visual
	_create_pet_visual()
	
	# Load room furniture
	_load_room_furniture()
	
	print("[HomeScreen] Ready")


func _process(delta: float) -> void:
	# Update pet stats over time
	GameManager.update_pet_stats(delta)


func _update_ui() -> void:
	if GameManager.pet_data:
		pet_name_label.text = GameManager.pet_data.name
		health_bar.value = GameManager.pet_data.health
		happy_bar.value = GameManager.pet_data.happiness
		hygiene_bar.value = GameManager.pet_data.hygiene
	
	coin_label.text = str(GameManager.coins)


func _on_coins_changed(new_amount: int) -> void:
	coin_label.text = str(new_amount)


func _on_stats_changed() -> void:
	if GameManager.pet_data:
		health_bar.value = GameManager.pet_data.health
		happy_bar.value = GameManager.pet_data.happiness
		hygiene_bar.value = GameManager.pet_data.hygiene
		
		# Update pet mood visual
		_update_pet_mood()


func _update_pet_mood() -> void:
	if pet_sprite == null or GameManager.pet_data == null:
		return
	
	if pet_sprite.has_method("set_mood"):
		var PetMood = pet_sprite.PetMood
		if GameManager.pet_data.happiness > 70 and GameManager.pet_data.health > 50:
			pet_sprite.set_mood(PetMood.HAPPY)
		elif GameManager.pet_data.happiness < 30:
			pet_sprite.set_mood(PetMood.SAD)
		elif GameManager.pet_data.health < 40:
			pet_sprite.set_mood(PetMood.HUNGRY)
		else:
			pet_sprite.set_mood(PetMood.NORMAL)


func _create_pet_visual() -> void:
	# Clear existing
	for child in pet_container.get_children():
		child.queue_free()
	
	if GameManager.pet_data == null:
		return
	
	# Create the pet sprite using our custom drawn pet
	var pet_script = preload("res://scripts/components/pet_sprite.gd")
	var pet_node = Node2D.new()
	pet_node.set_script(pet_script)
	pet_node.position = Vector2(200, 380)
	pet_node.scale = Vector2(1.2, 1.2)  # Make it a bit bigger
	pet_node.pet_color = GameManager.pet_data.primary_color
	
	# Set mood based on stats
	if GameManager.pet_data.happiness > 70:
		pet_node.current_mood = pet_node.PetMood.HAPPY
	elif GameManager.pet_data.happiness < 30:
		pet_node.current_mood = pet_node.PetMood.SAD
	elif GameManager.pet_data.health < 40:
		pet_node.current_mood = pet_node.PetMood.HUNGRY
	else:
		pet_node.current_mood = pet_node.PetMood.NORMAL
	
	pet_container.add_child(pet_node)
	pet_sprite = pet_node
	
	# Add bobbing animation
	_start_idle_animation()


func _start_idle_animation() -> void:
	if pet_sprite == null:
		return
	
	# Simple bobbing animation
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(pet_sprite, "position:y", 345.0, 0.8).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(pet_sprite, "position:y", 355.0, 0.8).set_ease(Tween.EASE_IN_OUT)


func _load_room_furniture() -> void:
	# Clear existing furniture
	for child in furniture_container.get_children():
		child.queue_free()
	
	# Load placed furniture from save data
	var furniture_list = GameManager.get_room_furniture()
	
	for furniture in furniture_list:
		var item = ItemDatabase.get_item(furniture["item_id"])
		if item:
			var node = _create_furniture_node(furniture, item)
			furniture_container.add_child(node)
	
	print("[HomeScreen] Loaded ", furniture_list.size(), " furniture items")


func _create_furniture_node(furniture: Dictionary, item: ItemData) -> Node2D:
	var node = Node2D.new()
	node.position = Vector2(furniture["position_x"], furniture["position_y"])
	node.set_meta("furniture_id", furniture["id"])
	node.set_meta("item_id", furniture["item_id"])
	
	# Try to load real asset texture
	var texture: Texture2D = null
	
	# Try loading by item hash if available (convert to string for lookup)
	if item.item_hash != 0:
		# Convert hash to hex string (same format as SWF filenames might be)
		var hash_str = "%X" % item.item_hash
		# Try loading texture by hash string (might need adjustment based on actual mapping)
		texture = AssetLoader.load_texture_by_filename(hash_str)
	
	# Try loading by sprite_path if set
	if texture == null and not item.sprite_path.is_empty():
		texture = AssetLoader.load_texture(item.sprite_path)
	
	# If we have a texture, use it
	if texture != null:
		var sprite = Sprite2D.new()
		sprite.texture = texture
		sprite.scale = Vector2(0.5, 0.5)  # Scale down if needed
		node.add_child(sprite)
	else:
		# Fallback: Placeholder visual (colored rect based on category)
		var visual = ColorRect.new()
		visual.size = Vector2(80, 60)
		visual.position = Vector2(-40, -30)  # Center it
		
		# Color based on item category
		match item.category:
			ItemDatabase.ItemCategory.FURNITURE:
				visual.color = Color(0.55, 0.4, 0.25)  # Brown for furniture
			ItemDatabase.ItemCategory.DECORATION:
				visual.color = Color(0.7, 0.6, 0.8)  # Purple for decor
			ItemDatabase.ItemCategory.FOOD:
				visual.color = Color(1.0, 0.8, 0.6)  # Orange/yellow for food
			ItemDatabase.ItemCategory.TOY:
				visual.color = Color(0.6, 0.8, 1.0)  # Light blue for toys
			_:
				visual.color = Color(0.6, 0.6, 0.6)  # Gray default
		
		node.add_child(visual)
	
	# Add label with item name (only if no texture or as debug info)
	if texture == null:
		var label = Label.new()
		label.text = item.name
		label.add_theme_font_size_override("font_size", 10)
		label.position = Vector2(-40, 35)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.custom_minimum_size.x = 80
		node.add_child(label)
	
	# Make interactive in edit mode
	if edit_mode:
		var area = Area2D.new()
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(80, 60)
		collision.shape = shape
		area.add_child(collision)
		area.input_event.connect(_on_furniture_input.bind(node))
		node.add_child(area)
	
	return node


func _on_furniture_input(viewport: Node, event: InputEvent, shape_idx: int, furniture_node: Node2D) -> void:
	if not edit_mode:
		return
	
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			dragging_item = furniture_node
			drag_offset = furniture_node.position - event.position


func _input(event: InputEvent) -> void:
	if dragging_item and event is InputEventMouseMotion:
		dragging_item.position = event.position + drag_offset
	
	if dragging_item and event is InputEventMouseButton:
		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			# Save new position
			var furniture_id = dragging_item.get_meta("furniture_id")
			GameManager.move_furniture(furniture_id, dragging_item.position)
			dragging_item = null


func _toggle_edit_mode() -> void:
	edit_mode = not edit_mode
	_load_room_furniture()  # Reload to add/remove interaction areas
	print("[HomeScreen] Edit mode: ", edit_mode)


## Feed button pressed
func _on_feed_pressed() -> void:
	AudioManager.play_click()
	
	# Check if player has food
	var has_food = false
	for item_id in GameManager.inventory:
		var item = ItemDatabase.get_item(item_id)
		if item and item.category == ItemDatabase.ItemCategory.FOOD:
			has_food = true
			break
	
	if not has_food:
		_show_action_effect("No food! Visit the shop.")
		return
	
	# Open food selection popup
	var popup_scene = preload("res://scenes/components/food_popup.tscn")
	var popup = popup_scene.instantiate()
	popup.food_selected.connect(_on_food_selected)
	add_child(popup)


func _on_food_selected(item: ItemData) -> void:
	GameManager.feed_pet(item.food_value)
	GameManager.remove_item(item.id)
	_show_action_effect("🍎 +" + str(item.food_value) + " Health!")
	print("[HomeScreen] Fed pet with: ", item.name)


## Wash button pressed
func _on_wash_pressed() -> void:
	AudioManager.play_click()
	GameManager.wash_pet(30)
	_show_action_effect("🛁 +30 Clean!")
	print("[HomeScreen] Washed pet")


## Play button pressed
func _on_play_pressed() -> void:
	AudioManager.play_click()
	GameManager.play_with_pet(25)
	_show_action_effect("🎾 +25 Happy!")
	print("[HomeScreen] Played with pet")


## Shop button pressed
func _on_shop_pressed() -> void:
	AudioManager.play_click()
	get_tree().change_scene_to_file("res://scenes/screens/shop_screen.tscn")


## Inventory button pressed
func _on_inventory_pressed() -> void:
	AudioManager.play_click()
	get_tree().change_scene_to_file("res://scenes/screens/inventory_screen.tscn")


## Menu button pressed
func _on_menu_pressed() -> void:
	AudioManager.play_click()
	# TODO: Show menu popup
	# For now, go back to main menu
	get_tree().change_scene_to_file("res://scenes/screens/main_menu.tscn")


## Show floating action effect text
func _show_action_effect(text: String) -> void:
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color(0.2, 0.6, 0.2))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(size.x / 2 - 80, size.y / 2)
	add_child(label)
	
	# Animate and remove
	var tween = create_tween()
	tween.tween_property(label, "position:y", label.position.y - 100, 1.0)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(label.queue_free)


