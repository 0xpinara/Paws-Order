extends Control
## PetCreator - Screen for creating a new pet

@onready var color_grid: GridContainer = $OptionsPanel/VBox/ColorGrid
@onready var name_input: LineEdit = $OptionsPanel/VBox/NameContainer/NameInput
@onready var pet_preview: Panel = $PetPreview
@onready var create_button: Button = $BottomPanel/HBox/CreateButton

# Currently selected values
var selected_color: Color = Color.WHITE
var pet_name: String = ""
var selected_body_type: int = 0
var selected_face_type: int = 0
var selected_ear_type: int = 0
var selected_gender: int = 0  # 0 = male, 1 = female

# Available pet colors (matching original Pet Society palette)
var pet_colors: Array[Color] = [
	Color("#F5DEB3"),  # Wheat (default tan)
	Color("#FFDAB9"),  # Peach
	Color("#FFC0CB"),  # Pink
	Color("#FFB6C1"),  # Light Pink
	Color("#DDA0DD"),  # Plum
	Color("#E6E6FA"),  # Lavender
	Color("#B0E0E6"),  # Powder Blue
	Color("#87CEEB"),  # Sky Blue
	Color("#98FB98"),  # Pale Green
	Color("#90EE90"),  # Light Green
	Color("#F0E68C"),  # Khaki
	Color("#FFE4B5"),  # Moccasin
	Color("#D2B48C"),  # Tan
	Color("#BC8F8F"),  # Rosy Brown
	Color("#A0522D"),  # Sienna
	Color("#8B4513"),  # Saddle Brown
	Color("#696969"),  # Dim Gray
	Color("#808080"),  # Gray
	Color("#A9A9A9"),  # Dark Gray
	Color("#C0C0C0"),  # Silver
	Color("#DCDCDC"),  # Gainsboro
	Color("#FFFFFF"),  # White
	Color("#000000"),  # Black
	Color("#8B0000"),  # Dark Red
]

# Feature options
const BODY_TYPES = ["Normal", "Chubby", "Slim", "Tiny"]
const FACE_TYPES = ["Round", "Square", "Triangle", "Oval"]
const EAR_TYPES = ["Pointed", "Round", "Floppy", "Small"]


func _ready() -> void:
	_setup_color_buttons()
	_setup_feature_buttons()
	_select_color(pet_colors[0])
	name_input.text_changed.connect(_on_name_changed)
	_update_create_button()
	_update_preview()
	print("[PetCreator] Ready")


func _setup_feature_buttons() -> void:
	# Add feature selection buttons dynamically if the containers exist
	# This will be expanded when we have the proper UI layout
	pass


func _setup_color_buttons() -> void:
	# Clear existing
	for child in color_grid.get_children():
		child.queue_free()
	
	# Create color buttons
	for color in pet_colors:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(36, 36)
		
		# Create a StyleBoxFlat for the button
		var style = StyleBoxFlat.new()
		style.bg_color = color
		style.border_width_left = 2
		style.border_width_right = 2
		style.border_width_top = 2
		style.border_width_bottom = 2
		style.border_color = Color(0.3, 0.3, 0.3, 0.5)
		style.corner_radius_top_left = 4
		style.corner_radius_top_right = 4
		style.corner_radius_bottom_left = 4
		style.corner_radius_bottom_right = 4
		
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)
		
		btn.pressed.connect(_on_color_button_pressed.bind(color))
		color_grid.add_child(btn)


func _on_color_button_pressed(color: Color) -> void:
	AudioManager.play_click()
	_select_color(color)


func _select_color(color: Color) -> void:
	selected_color = color
	_update_preview()
	
	# Update button borders to show selection
	var index = pet_colors.find(color)
	for i in range(color_grid.get_child_count()):
		var btn = color_grid.get_child(i) as Button
		if btn:
			var style = btn.get_theme_stylebox("normal") as StyleBoxFlat
			if style:
				if i == index:
					style.border_color = Color(0.2, 0.6, 0.2, 1)  # Green border for selected
					style.border_width_left = 3
					style.border_width_right = 3
					style.border_width_top = 3
					style.border_width_bottom = 3
				else:
					style.border_color = Color(0.3, 0.3, 0.3, 0.5)
					style.border_width_left = 2
					style.border_width_right = 2
					style.border_width_top = 2
					style.border_width_bottom = 2


func _update_preview() -> void:
	# Update the pet preview with selected color
	# For now, just change the panel color as a placeholder
	var style = StyleBoxFlat.new()
	style.bg_color = selected_color.lightened(0.3)
	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_left = 20
	style.corner_radius_bottom_right = 20
	pet_preview.add_theme_stylebox_override("panel", style)
	
	# TODO: Update actual pet sprite when we have assets


func _on_name_changed(new_text: String) -> void:
	pet_name = new_text.strip_edges()
	_update_create_button()


func _update_create_button() -> void:
	# Enable create button only if name is valid
	create_button.disabled = pet_name.length() < 1


func _on_back_pressed() -> void:
	AudioManager.play_click()
	get_tree().change_scene_to_file("res://scenes/screens/main_menu.tscn")


func _on_create_pressed() -> void:
	if pet_name.length() < 1:
		# Show error - name required
		print("[PetCreator] Error: Name required")
		return
	
	AudioManager.play_click()
	
	# Create the pet with all selected features
	var features = {
		"body_type": selected_body_type,
		"face_type": selected_face_type,
		"ear_type": selected_ear_type,
		"gender": selected_gender,
	}
	
	GameManager.create_pet(pet_name, selected_color, features)
	
	# Give starter food items
	GameManager.add_item(1001)  # Apple
	GameManager.add_item(1001)  # Apple
	GameManager.add_item(1002)  # Bread
	GameManager.add_item(1003)  # Cookie
	
	print("[PetCreator] Pet created: ", pet_name, " with color ", selected_color)
	
	# Go to home screen
	get_tree().change_scene_to_file("res://scenes/screens/home_screen.tscn")

