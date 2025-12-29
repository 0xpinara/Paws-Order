extends Control
## FoodPopup - Popup to select food to feed pet
class_name FoodPopup

signal food_selected(item: ItemData)
signal closed()

@onready var food_grid: VBoxContainer = $Panel/VBox/FoodList/FoodGrid


func _ready() -> void:
	_load_food_items()


func _load_food_items() -> void:
	# Clear existing
	for child in food_grid.get_children():
		child.queue_free()
	
	# Get food items from inventory
	var food_items: Dictionary = {}  # item_id -> count
	
	for item_id in GameManager.inventory:
		var item = ItemDatabase.get_item(item_id)
		if item and item.category == ItemDatabase.ItemCategory.FOOD:
			if item_id in food_items:
				food_items[item_id] += 1
			else:
				food_items[item_id] = 1
	
	if food_items.is_empty():
		var empty_label = Label.new()
		empty_label.text = "No food in inventory!\nVisit the shop to buy some."
		empty_label.add_theme_font_size_override("font_size", 14)
		empty_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		food_grid.add_child(empty_label)
		return
	
	# Create food item rows
	for item_id in food_items.keys():
		var item = ItemDatabase.get_item(item_id)
		var count = food_items[item_id]
		var row = _create_food_row(item, count)
		food_grid.add_child(row)


func _create_food_row(item: ItemData, count: int) -> Control:
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	
	# Icon placeholder
	var icon = Panel.new()
	icon.custom_minimum_size = Vector2(50, 50)
	var icon_style = StyleBoxFlat.new()
	icon_style.bg_color = Color(0.9, 0.85, 0.75)
	icon_style.corner_radius_top_left = 6
	icon_style.corner_radius_top_right = 6
	icon_style.corner_radius_bottom_left = 6
	icon_style.corner_radius_bottom_right = 6
	icon.add_theme_stylebox_override("panel", icon_style)
	hbox.add_child(icon)
	
	# Info container
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var name_label = Label.new()
	name_label.text = item.name + " (x" + str(count) + ")"
	name_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(name_label)
	
	var health_label = Label.new()
	health_label.text = "❤️ +" + str(item.food_value) + " Health"
	health_label.add_theme_font_size_override("font_size", 12)
	health_label.add_theme_color_override("font_color", Color(0.6, 0.4, 0.4))
	vbox.add_child(health_label)
	
	hbox.add_child(vbox)
	
	# Feed button
	var feed_btn = Button.new()
	feed_btn.text = "Feed"
	feed_btn.custom_minimum_size = Vector2(70, 40)
	feed_btn.add_theme_font_size_override("font_size", 14)
	feed_btn.pressed.connect(_on_feed_pressed.bind(item))
	hbox.add_child(feed_btn)
	
	return hbox


func _on_feed_pressed(item: ItemData) -> void:
	AudioManager.play_click()
	food_selected.emit(item)
	queue_free()


func _on_close_pressed() -> void:
	AudioManager.play_click()
	closed.emit()
	queue_free()


func _input(event: InputEvent) -> void:
	# Close on overlay click
	if event is InputEventMouseButton and event.pressed:
		var overlay = $Overlay
		if overlay.get_global_rect().has_point(event.position):
			var panel = $Panel
			if not panel.get_global_rect().has_point(event.position):
				_on_close_pressed()

