extends Control
## InventoryScreen - View and manage owned items

@onready var items_grid: GridContainer = $ItemsContainer/ItemsGrid
@onready var category_tabs: HBoxContainer = $CategoryTabs
@onready var count_label: Label = $Header/HBox/CountLabel
@onready var empty_label: Label = $EmptyLabel
@onready var action_panel: Panel = $ActionPanel
@onready var item_name_label: Label = $ActionPanel/VBox/ItemName
@onready var use_button: Button = $ActionPanel/VBox/HBox/UseButton
@onready var place_button: Button = $ActionPanel/VBox/HBox/PlaceButton

var current_category: int = 0  # 0 = all, 1 = food, 2 = furniture, 3 = clothes
var selected_item_index: int = -1
var selected_item_data: ItemData = null


func _ready() -> void:
	_load_items(0)
	action_panel.visible = false
	print("[InventoryScreen] Ready")


func _on_back_pressed() -> void:
	AudioManager.play_click()
	get_tree().change_scene_to_file("res://scenes/screens/home_screen.tscn")


func _on_category_pressed(category_index: int) -> void:
	AudioManager.play_click()
	
	# Update tab visuals
	for i in range(category_tabs.get_child_count()):
		var tab = category_tabs.get_child(i) as Button
		if tab:
			tab.button_pressed = (i == category_index)
	
	current_category = category_index
	_deselect_item()
	_load_items(category_index)


func _load_items(category_index: int) -> void:
	# Clear existing items
	for child in items_grid.get_children():
		child.queue_free()
	
	# Group inventory by item ID and count
	var item_counts: Dictionary = {}
	for item_id in GameManager.inventory:
		if item_id in item_counts:
			item_counts[item_id] += 1
		else:
			item_counts[item_id] = 1
	
	# Filter by category
	var filtered_items: Array = []
	for item_id in item_counts.keys():
		var item = ItemDatabase.get_item(item_id)
		if item == null:
			continue
		
		var include = false
		match category_index:
			0:  # All
				include = true
			1:  # Food
				include = (item.category == ItemDatabase.ItemCategory.FOOD)
			2:  # Furniture
				include = (item.category == ItemDatabase.ItemCategory.FURNITURE or 
						   item.category == ItemDatabase.ItemCategory.DECORATION)
			3:  # Clothes
				include = (item.category == ItemDatabase.ItemCategory.CLOTHING_HAT or
						   item.category == ItemDatabase.ItemCategory.CLOTHING_SHIRT or
						   item.category == ItemDatabase.ItemCategory.CLOTHING_PANTS or
						   item.category == ItemDatabase.ItemCategory.CLOTHING_SHOES)
		
		if include:
			filtered_items.append({"item": item, "count": item_counts[item_id]})
	
	# Update count label
	var total_count = GameManager.inventory.size()
	count_label.text = str(total_count) + " item" + ("s" if total_count != 1 else "")
	
	# Show empty message if no items
	empty_label.visible = filtered_items.is_empty()
	
	# Create item cards
	for data in filtered_items:
		var card = _create_item_card(data.item, data.count)
		items_grid.add_child(card)


func _create_item_card(item: ItemData, count: int) -> Control:
	var card = Panel.new()
	card.custom_minimum_size = Vector2(85, 100)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 0.95)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_width_bottom = 2
	style.border_color = Color(0.85, 0.85, 0.85)
	card.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 3)
	card.add_child(vbox)
	
	# Item icon placeholder
	var icon = Panel.new()
	icon.custom_minimum_size = Vector2(60, 50)
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var icon_style = StyleBoxFlat.new()
	icon_style.bg_color = Color(0.92, 0.92, 0.88)
	icon_style.corner_radius_top_left = 4
	icon_style.corner_radius_top_right = 4
	icon_style.corner_radius_bottom_left = 4
	icon_style.corner_radius_bottom_right = 4
	icon.add_theme_stylebox_override("panel", icon_style)
	vbox.add_child(icon)
	
	# Item name
	var name_label = Label.new()
	name_label.text = item.name
	name_label.add_theme_font_size_override("font_size", 10)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	name_label.custom_minimum_size.y = 25
	vbox.add_child(name_label)
	
	# Count badge if more than 1
	if count > 1:
		var count_badge = Label.new()
		count_badge.text = "x" + str(count)
		count_badge.add_theme_font_size_override("font_size", 12)
		count_badge.add_theme_color_override("font_color", Color(0.3, 0.3, 0.3))
		count_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(count_badge)
	
	# Make clickable
	var button = Button.new()
	button.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.flat = true
	button.pressed.connect(_on_item_selected.bind(item))
	card.add_child(button)
	
	return card


func _on_item_selected(item: ItemData) -> void:
	AudioManager.play_click()
	selected_item_data = item
	selected_item_index = GameManager.inventory.find(item.id)
	
	# Update action panel
	item_name_label.text = item.name
	
	# Show/hide buttons based on item type
	use_button.visible = (item.category == ItemDatabase.ItemCategory.FOOD)
	place_button.visible = (item.category == ItemDatabase.ItemCategory.FURNITURE or
							item.category == ItemDatabase.ItemCategory.DECORATION)
	
	action_panel.visible = true


func _deselect_item() -> void:
	selected_item_data = null
	selected_item_index = -1
	action_panel.visible = false


func _on_use_pressed() -> void:
	if selected_item_data == null:
		return
	
	AudioManager.play_click()
	
	# Use food item
	if selected_item_data.category == ItemDatabase.ItemCategory.FOOD:
		GameManager.feed_pet(selected_item_data.food_value)
		GameManager.remove_item(selected_item_data.id)
		print("[Inventory] Used food: ", selected_item_data.name)
	
	_deselect_item()
	_load_items(current_category)


func _on_place_pressed() -> void:
	if selected_item_data == null:
		return
	
	AudioManager.play_click()
	# TODO: Go to room edit mode to place furniture
	print("[Inventory] Place item: ", selected_item_data.name)
	
	_deselect_item()


func _on_sell_pressed() -> void:
	if selected_item_data == null:
		return
	
	AudioManager.play_click()
	
	var sell_price = selected_item_data.price / 2
	GameManager.add_coins(sell_price)
	GameManager.remove_item(selected_item_data.id)
	
	print("[Inventory] Sold ", selected_item_data.name, " for ", sell_price, " coins")
	
	_deselect_item()
	_load_items(current_category)

