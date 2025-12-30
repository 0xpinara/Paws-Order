extends Control
## ShopScreen - Where players buy items

@onready var coin_label: Label = $Header/HBox/CoinLabel
@onready var items_grid: GridContainer = $ItemsContainer/ItemsGrid
@onready var category_tabs: HBoxContainer = $CategoryTabs

# Category mapping
var category_map = {
	0: ItemDatabase.ItemCategory.FOOD,
	1: ItemDatabase.ItemCategory.FURNITURE,
	2: ItemDatabase.ItemCategory.DECORATION,
	3: ItemDatabase.ItemCategory.CLOTHING_HAT,  # Shows all clothing
	4: ItemDatabase.ItemCategory.TOY,
}

var current_category: int = 0


func _ready() -> void:
	GameManager.coins_changed.connect(_on_coins_changed)
	_update_coins()
	_load_items(0)
	print("[ShopScreen] Ready")


func _update_coins() -> void:
	coin_label.text = str(GameManager.coins)


func _on_coins_changed(new_amount: int) -> void:
	coin_label.text = str(new_amount)


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
	_load_items(category_index)


func _load_items(category_index: int) -> void:
	# Clear existing items
	for child in items_grid.get_children():
		child.queue_free()
	
	# Get items for category
	var category = category_map.get(category_index, ItemDatabase.ItemCategory.FOOD)
	var items = ItemDatabase.get_items_by_category(category)
	
	# If clothing category, include all clothing types
	if category_index == 3:
		items = []
		items.append_array(ItemDatabase.get_items_by_category(ItemDatabase.ItemCategory.CLOTHING_HAT))
		items.append_array(ItemDatabase.get_items_by_category(ItemDatabase.ItemCategory.CLOTHING_SHIRT))
		items.append_array(ItemDatabase.get_items_by_category(ItemDatabase.ItemCategory.CLOTHING_PANTS))
		items.append_array(ItemDatabase.get_items_by_category(ItemDatabase.ItemCategory.CLOTHING_SHOES))
	
	# Create item cards
	for item in items:
		var card = _create_item_card(item)
		items_grid.add_child(card)


func _create_item_card(item: ItemData) -> Control:
	var card = Panel.new()
	card.custom_minimum_size = Vector2(110, 140)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 0.9)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_width_bottom = 2
	style.border_color = Color(0.8, 0.8, 0.8)
	card.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 5)
	card.add_child(vbox)
	
	# Item icon placeholder
	var icon_container = Panel.new()
	icon_container.custom_minimum_size = Vector2(80, 60)
	icon_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var icon_style = StyleBoxFlat.new()
	icon_style.bg_color = Color(0.9, 0.9, 0.85)
	icon_style.corner_radius_top_left = 4
	icon_style.corner_radius_top_right = 4
	icon_style.corner_radius_bottom_left = 4
	icon_style.corner_radius_bottom_right = 4
	icon_container.add_theme_stylebox_override("panel", icon_style)
	vbox.add_child(icon_container)
	
	# Item name
	var name_label = Label.new()
	name_label.text = item.name
	name_label.add_theme_font_size_override("font_size", 12)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(name_label)
	
	# Price
	var price_label = Label.new()
	price_label.text = "🪙 " + str(item.price)
	price_label.add_theme_font_size_override("font_size", 14)
	price_label.add_theme_color_override("font_color", Color(0.6, 0.5, 0.1))
	price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(price_label)
	
	# Buy button
	var buy_btn = Button.new()
	buy_btn.text = "Buy"
	buy_btn.add_theme_font_size_override("font_size", 12)
	buy_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	buy_btn.custom_minimum_size = Vector2(60, 28)
	buy_btn.pressed.connect(_on_buy_pressed.bind(item))
	
	# Disable if can't afford
	if GameManager.coins < item.price:
		buy_btn.disabled = true
	
	vbox.add_child(buy_btn)
	
	return card


func _on_buy_pressed(item: ItemData) -> void:
	if GameManager.spend_coins(item.price):
		AudioManager.play_coin()
		GameManager.add_item(item.id)
		
		# Show purchase feedback
		_show_purchase_feedback(item.name)
		
		# Refresh to update button states
		_load_items(current_category)
		
		print("[ShopScreen] Bought: ", item.name)
	else:
		print("[ShopScreen] Can't afford: ", item.name)


func _show_purchase_feedback(item_name: String) -> void:
	var label = Label.new()
	label.text = "Bought " + item_name + "!"
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(0.2, 0.6, 0.2))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_CENTER)
	label.position.y = 300
	add_child(label)
	
	var tween = create_tween()
	tween.tween_property(label, "position:y", 250, 0.8)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8)
	tween.tween_callback(label.queue_free)


