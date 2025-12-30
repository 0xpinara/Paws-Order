extends Node
## AudioManager - Handles all game audio
## Background music, sound effects, and volume control

# Audio players
var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_PLAYERS = 8

# Volume settings (0.0 to 1.0)
var music_volume: float = 0.7:
	set(value):
		music_volume = clamp(value, 0.0, 1.0)
		if music_player:
			music_player.volume_db = linear_to_db(music_volume)

var sfx_volume: float = 1.0:
	set(value):
		sfx_volume = clamp(value, 0.0, 1.0)

var music_enabled: bool = true
var sfx_enabled: bool = true


func _ready() -> void:
	_setup_audio_players()
	print("[AudioManager] Initialized")


func _setup_audio_players() -> void:
	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	
	# Create SFX player pool
	for i in range(MAX_SFX_PLAYERS):
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		sfx_players.append(player)


## Play background music
func play_music(stream: AudioStream, fade_in: float = 0.5) -> void:
	if not music_enabled:
		return
	
	music_player.stream = stream
	music_player.volume_db = linear_to_db(music_volume)
	music_player.play()
	
	# TODO: Add fade in effect


## Stop background music
func stop_music(fade_out: float = 0.5) -> void:
	music_player.stop()
	# TODO: Add fade out effect


## Play sound effect
func play_sfx(stream: AudioStream, pitch_variation: float = 0.0) -> void:
	if not sfx_enabled:
		return
	
	# Find available player
	for player in sfx_players:
		if not player.playing:
			player.stream = stream
			player.volume_db = linear_to_db(sfx_volume)
			if pitch_variation > 0:
				player.pitch_scale = randf_range(1.0 - pitch_variation, 1.0 + pitch_variation)
			else:
				player.pitch_scale = 1.0
			player.play()
			return
	
	# All players busy - use first one anyway
	sfx_players[0].stream = stream
	sfx_players[0].volume_db = linear_to_db(sfx_volume)
	sfx_players[0].play()


## Play UI click sound
func play_click() -> void:
	# TODO: Load and play click sound
	pass


## Play coin sound
func play_coin() -> void:
	# TODO: Load and play coin sound
	pass


