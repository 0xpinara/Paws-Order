extends Control
## MainMenu - The game's main menu screen

@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var new_game_button: Button = $VBoxContainer/NewGameButton


func _ready() -> void:
	# Try to load existing save
	var has_save = SaveManager.load_game()
	
	# Update button visibility based on save state
	play_button.visible = has_save and GameManager.has_pet
	new_game_button.text = "New Game" if has_save else "Start Game"
	
	print("[MainMenu] Ready - Has save: ", has_save, ", Has pet: ", GameManager.has_pet)


func _on_play_pressed() -> void:
	# Go to home screen
	AudioManager.play_click()
	get_tree().change_scene_to_file("res://scenes/screens/home_screen.tscn")


func _on_new_game_pressed() -> void:
	AudioManager.play_click()
	
	# If there's an existing save, ask for confirmation
	if SaveManager.has_save() and GameManager.has_pet:
		# TODO: Show confirmation dialog
		GameManager.reset_game()
	
	# Go to pet creator
	get_tree().change_scene_to_file("res://scenes/screens/pet_creator.tscn")


func _on_settings_pressed() -> void:
	AudioManager.play_click()
	# TODO: Show settings popup
	print("[MainMenu] Settings pressed")

