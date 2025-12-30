extends Node
## AssetLoader - Loads and caches game assets from the extracted SWF files
## Provides hash-based lookup compatible with original game

var asset_lookup: Dictionary = {}
var texture_cache: Dictionary = {}  # path -> Texture2D cache
var loading_queue: Array = []

func _ready() -> void:
	_load_asset_lookup()
	print("[AssetLoader] Initialized with ", asset_lookup.size(), " assets")

## Load asset lookup JSON file
func _load_asset_lookup() -> void:
	var lookup_file = "res://assets/sprites/asset_lookup.json"
	
	if not ResourceLoader.exists(lookup_file):
		print("[AssetLoader] Warning: asset_lookup.json not found at ", lookup_file)
		return
	
	var file = FileAccess.open(lookup_file, FileAccess.READ)
	if file == null:
		print("[AssetLoader] Error: Could not open asset_lookup.json")
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		print("[AssetLoader] Error parsing JSON: ", json.get_error_message())
		return
	
	asset_lookup = json.data
	print("[AssetLoader] Loaded ", asset_lookup.size(), " asset entries")

## Load texture by SWF filename (original asset ID)
func load_texture_by_filename(filename: String) -> Texture2D:
	if filename.is_empty():
		return null
	
	# Remove extension if present
	var base_name = filename.get_basename()
	
	# Check lookup
	if not asset_lookup.has(base_name):
		# Try direct path lookup as fallback
		var direct_path = "res://assets/sprites/lookup/" + base_name + ".png"
		if ResourceLoader.exists(direct_path):
			return load_texture(direct_path)
		print("[AssetLoader] Asset not found: ", base_name)
		return null
	
	var asset_data = asset_lookup[base_name]
	var asset_path = asset_data.get("path", "")
	
	if asset_path.is_empty():
		return null
	
	# Check cache first
	if texture_cache.has(asset_path):
		return texture_cache[asset_path]
	
	# Load texture
	var texture = load(asset_path) as Texture2D
	if texture == null:
		# Try alternative path (in case symlink doesn't work)
		var alt_path = "res://assets/sprites/lookup/" + base_name + ".png"
		if ResourceLoader.exists(alt_path):
			texture = load(alt_path) as Texture2D
		
		if texture == null:
			print("[AssetLoader] Failed to load texture: ", asset_path)
			return null
	
	# Cache it
	texture_cache[asset_path] = texture
	return texture

## Load texture by item hash (for compatibility with original game)
## Note: We don't have hash->filename mapping, so this is a placeholder
## You'll need to create a mapping file if you have item hash data
func load_texture_by_hash(item_hash: int) -> Texture2D:
	# TODO: Implement hash->filename mapping if available
	# For now, return null
	print("[AssetLoader] load_texture_by_hash not yet implemented")
	return null

## Load texture from asset path directly
func load_texture(asset_path: String) -> Texture2D:
	if asset_path.is_empty():
		return null
	
	# Check cache
	if texture_cache.has(asset_path):
		return texture_cache[asset_path]
	
	# Load texture
	var texture = load(asset_path) as Texture2D
	if texture == null:
		# Try with res:// prefix
		if not asset_path.begins_with("res://"):
			texture = load("res://" + asset_path) as Texture2D
		
		if texture == null:
			print("[AssetLoader] Failed to load texture: ", asset_path)
			return null
	
	# Cache it
	texture_cache[asset_path] = texture
	return texture

## Get random asset for testing
func get_random_asset() -> String:
	if asset_lookup.is_empty():
		return ""
	
	var keys = asset_lookup.keys()
	return keys[randi() % keys.size()]

## Clear texture cache to free memory
func clear_cache() -> void:
	texture_cache.clear()
	print("[AssetLoader] Texture cache cleared")

## Get asset info by filename
func get_asset_info(filename: String) -> Dictionary:
	var base_name = filename.get_basename()
	if asset_lookup.has(base_name):
		return asset_lookup[base_name]
	return {}

