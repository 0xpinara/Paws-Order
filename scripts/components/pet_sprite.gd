extends Node2D
class_name PetSprite
## PetSprite - Draws a cute placeholder pet until real sprites are available

@export var pet_color: Color = Color("#F5DEB3")
@export var eye_color: Color = Color.BLACK
@export var show_blush: bool = true

# Animation state
var blink_timer: float = 0.0
var is_blinking: bool = false
var mood_bounce: float = 0.0

# Mood affects expression
enum PetMood { HAPPY, NORMAL, SAD, HUNGRY, SLEEPY }
var current_mood: PetMood = PetMood.HAPPY


func _ready() -> void:
	# Start idle animation
	_start_idle_animation()


func _process(delta: float) -> void:
	# Random blinking
	blink_timer -= delta
	if blink_timer <= 0:
		if is_blinking:
			is_blinking = false
			blink_timer = randf_range(2.0, 5.0)
		else:
			is_blinking = true
			blink_timer = 0.15
		queue_redraw()


func _start_idle_animation() -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(self, "mood_bounce", 5.0, 0.6).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "mood_bounce", 0.0, 0.6).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(queue_redraw)


func set_color(color: Color) -> void:
	pet_color = color
	queue_redraw()


func set_mood(mood: PetMood) -> void:
	current_mood = mood
	queue_redraw()


func _draw() -> void:
	var offset_y = -mood_bounce
	
	# Body (oval)
	var body_center = Vector2(0, 20 + offset_y)
	var body_size = Vector2(50, 45)
	_draw_oval(body_center, body_size, pet_color)
	
	# Head (larger oval)
	var head_center = Vector2(0, -25 + offset_y)
	var head_size = Vector2(55, 50)
	_draw_oval(head_center, head_size, pet_color)
	
	# Ears
	_draw_ear(Vector2(-35, -55 + offset_y), true)
	_draw_ear(Vector2(35, -55 + offset_y), false)
	
	# Face
	_draw_face(Vector2(0, -25 + offset_y))
	
	# Arms
	_draw_arm(Vector2(-35, 10 + offset_y), true)
	_draw_arm(Vector2(35, 10 + offset_y), false)
	
	# Legs
	_draw_leg(Vector2(-18, 55 + offset_y))
	_draw_leg(Vector2(18, 55 + offset_y))


func _draw_oval(center: Vector2, size: Vector2, color: Color) -> void:
	var points = PackedVector2Array()
	for i in range(32):
		var angle = i * TAU / 32
		points.append(center + Vector2(cos(angle) * size.x / 2, sin(angle) * size.y / 2))
	draw_colored_polygon(points, color)
	# Outline
	draw_polyline(points, color.darkened(0.2), 2.0, true)


func _draw_ear(pos: Vector2, is_left: bool) -> void:
	var points = PackedVector2Array()
	if is_left:
		points.append(pos + Vector2(0, 25))
		points.append(pos + Vector2(-8, 0))
		points.append(pos + Vector2(15, 10))
	else:
		points.append(pos + Vector2(0, 25))
		points.append(pos + Vector2(8, 0))
		points.append(pos + Vector2(-15, 10))
	draw_colored_polygon(points, pet_color)
	draw_polyline(points, pet_color.darkened(0.2), 2.0, true)
	
	# Inner ear
	var inner_color = pet_color.lightened(0.3)
	var inner_points = PackedVector2Array()
	if is_left:
		inner_points.append(pos + Vector2(-2, 20))
		inner_points.append(pos + Vector2(-5, 5))
		inner_points.append(pos + Vector2(8, 12))
	else:
		inner_points.append(pos + Vector2(2, 20))
		inner_points.append(pos + Vector2(5, 5))
		inner_points.append(pos + Vector2(-8, 12))
	draw_colored_polygon(inner_points, inner_color)


func _draw_face(center: Vector2) -> void:
	# Eyes
	var eye_left = center + Vector2(-15, -5)
	var eye_right = center + Vector2(15, -5)
	
	if is_blinking:
		# Closed eyes (lines)
		draw_line(eye_left + Vector2(-6, 0), eye_left + Vector2(6, 0), eye_color, 2.0)
		draw_line(eye_right + Vector2(-6, 0), eye_right + Vector2(6, 0), eye_color, 2.0)
	else:
		# Open eyes
		match current_mood:
			PetMood.HAPPY:
				# Happy curved eyes
				_draw_happy_eye(eye_left)
				_draw_happy_eye(eye_right)
			PetMood.SAD:
				# Sad eyes
				_draw_sad_eye(eye_left)
				_draw_sad_eye(eye_right)
			_:
				# Normal round eyes
				draw_circle(eye_left, 7, Color.WHITE)
				draw_circle(eye_left, 5, eye_color)
				draw_circle(eye_left + Vector2(1, -1), 2, Color.WHITE)
				
				draw_circle(eye_right, 7, Color.WHITE)
				draw_circle(eye_right, 5, eye_color)
				draw_circle(eye_right + Vector2(1, -1), 2, Color.WHITE)
	
	# Nose
	var nose_pos = center + Vector2(0, 5)
	draw_circle(nose_pos, 5, Color(0.3, 0.2, 0.2))
	draw_circle(nose_pos + Vector2(-1, -1), 2, Color(0.5, 0.4, 0.4))
	
	# Mouth
	var mouth_center = center + Vector2(0, 15)
	match current_mood:
		PetMood.HAPPY:
			_draw_smile(mouth_center)
		PetMood.SAD:
			_draw_frown(mouth_center)
		_:
			_draw_neutral_mouth(mouth_center)
	
	# Blush
	if show_blush and current_mood == PetMood.HAPPY:
		draw_circle(center + Vector2(-25, 5), 8, Color(1, 0.6, 0.6, 0.5))
		draw_circle(center + Vector2(25, 5), 8, Color(1, 0.6, 0.6, 0.5))


func _draw_happy_eye(pos: Vector2) -> void:
	# Curved happy eye
	var points = PackedVector2Array()
	for i in range(10):
		var t = float(i) / 9.0
		var x = lerp(-6.0, 6.0, t)
		var y = -abs(x) * 0.8
		points.append(pos + Vector2(x, y))
	draw_polyline(points, eye_color, 3.0)


func _draw_sad_eye(pos: Vector2) -> void:
	draw_circle(pos, 7, Color.WHITE)
	draw_circle(pos, 5, eye_color)
	draw_circle(pos + Vector2(0, 1), 2, Color.WHITE)
	# Sad eyebrow
	draw_line(pos + Vector2(-8, -10), pos + Vector2(0, -6), eye_color, 2.0)


func _draw_smile(pos: Vector2) -> void:
	var points = PackedVector2Array()
	for i in range(10):
		var t = float(i) / 9.0
		var x = lerp(-12.0, 12.0, t)
		var y = (x * x) * 0.03
		points.append(pos + Vector2(x, y))
	draw_polyline(points, Color(0.3, 0.2, 0.2), 2.5)


func _draw_frown(pos: Vector2) -> void:
	var points = PackedVector2Array()
	for i in range(10):
		var t = float(i) / 9.0
		var x = lerp(-10.0, 10.0, t)
		var y = -(x * x) * 0.02
		points.append(pos + Vector2(x, y + 5))
	draw_polyline(points, Color(0.3, 0.2, 0.2), 2.5)


func _draw_neutral_mouth(pos: Vector2) -> void:
	draw_line(pos + Vector2(-8, 0), pos + Vector2(8, 0), Color(0.3, 0.2, 0.2), 2.0)


func _draw_arm(pos: Vector2, is_left: bool) -> void:
	var arm_end = pos + Vector2(-15 if is_left else 15, 20)
	
	# Arm
	var points = PackedVector2Array()
	points.append(pos)
	points.append(pos + Vector2(-5 if is_left else 5, 10))
	points.append(arm_end)
	points.append(arm_end + Vector2(5 if is_left else -5, -5))
	draw_colored_polygon(points, pet_color)
	
	# Hand (small circle)
	draw_circle(arm_end, 8, pet_color)
	draw_arc(arm_end, 8, 0, TAU, 16, pet_color.darkened(0.2), 1.5)


func _draw_leg(pos: Vector2) -> void:
	# Leg
	draw_circle(pos, 12, pet_color)
	draw_arc(pos, 12, 0, TAU, 16, pet_color.darkened(0.2), 1.5)
	
	# Foot detail
	draw_circle(pos + Vector2(0, 5), 4, pet_color.darkened(0.1))

