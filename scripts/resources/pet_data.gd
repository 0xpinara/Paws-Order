extends Resource
class_name PetData
## PetData - Stores all information about the player's pet

# Basic Info
@export var name: String = "Pet"
@export var primary_color: Color = Color.WHITE
@export var secondary_color: Color = Color.WHITE
@export var features: Dictionary = {}  # face, ears, body type, etc.

# Stats (0-100)
@export var health: float = 100.0
@export var happiness: float = 100.0
@export var hygiene: float = 100.0

# Progression
@export var level: int = 1
@export var experience: int = 0
@export var birthday: int = 0  # Unix timestamp

# Clothing equipped (item IDs)
@export var equipped_hat: int = 0
@export var equipped_shirt: int = 0
@export var equipped_pants: int = 0
@export var equipped_shoes: int = 0
@export var equipped_accessory: int = 0

# Pet mood based on stats
enum Mood { HAPPY, CONTENT, SAD, HUNGRY, DIRTY, SICK }


## Get current mood based on stats
func get_mood() -> Mood:
	if health < 20:
		return Mood.SICK
	if health < 40:
		return Mood.HUNGRY
	if hygiene < 30:
		return Mood.DIRTY
	if happiness < 30:
		return Mood.SAD
	if happiness > 70 and health > 70:
		return Mood.HAPPY
	return Mood.CONTENT


## Get mood as string
func get_mood_string() -> String:
	match get_mood():
		Mood.HAPPY: return "Happy"
		Mood.CONTENT: return "Content"
		Mood.SAD: return "Sad"
		Mood.HUNGRY: return "Hungry"
		Mood.DIRTY: return "Dirty"
		Mood.SICK: return "Sick"
	return "Unknown"


## Add experience and handle level up
func add_experience(amount: int) -> bool:
	experience += amount
	var leveled_up = false
	
	while experience >= get_experience_for_next_level():
		experience -= get_experience_for_next_level()
		level += 1
		leveled_up = true
	
	return leveled_up


## Get experience needed for next level
func get_experience_for_next_level() -> int:
	return level * 100 + 50


## Get overall stat average
func get_overall_wellbeing() -> float:
	return (health + happiness + hygiene) / 3.0


