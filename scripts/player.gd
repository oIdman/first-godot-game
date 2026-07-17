extends Area2D

@export var speed := 400.0
@export var shield_time := 0.0  # remaining shield time, 0 = no shield
@export var boost_multiplier := 1.0
@export var boost_time := 0.0

var screen_size := Vector2.ZERO
var active := false

signal hit
signal shield_broken


func _ready():
	screen_size = get_viewport_rect().size
	collision_layer = 1
	collision_mask = 2 | 4  # Detect enemies (layer 2) AND power-ups (layer 4)
	area_entered.connect(_on_area_entered)
	hide()


func _process(delta):
	if not active:
		return

	# Movement
	var velocity := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	# Tick power-up timers
	if shield_time > 0.0:
		shield_time -= delta
		if shield_time <= 0.0:
			shield_time = 0.0

	if boost_time > 0.0:
		boost_time -= delta
		if boost_time <= 0.0:
			boost_time = 0.0
			boost_multiplier = 1.0

	queue_redraw()


func _on_area_entered(area: Area2D):
	if not active:
		return

	if area.is_in_group("enemy"):
		if shield_time > 0.0:
			# Shield blocks one hit
			shield_time = 0.0
			shield_broken.emit()
			SoundManager.play_shield_break()
		else:
			hit.emit()

	elif area.is_in_group("powerup"):
		var pu := area as Area2D
		if pu != null and pu.has_method("get_pu_type"):
			SoundManager.play_pickup()
			_apply_powerup(pu.get_pu_type())
			pu.queue_free()


func _apply_powerup(pu_type: int):
	match pu_type:
		0:  # SHIELD
			shield_time = 8.0
		1:  # SCORE_BOOST
			boost_multiplier = 2.0
			boost_time = 5.0


func _draw():
	# Draw player body
	draw_circle(Vector2.ZERO, 18, Color.GREEN_YELLOW)
	draw_circle(Vector2.ZERO, 12, Color.LIME_GREEN)

	# Shield visual
	if shield_time > 0.0:
		var alpha := 0.3 + 0.2 * sin(Time.get_ticks_msec() * 0.005)
		draw_circle(Vector2.ZERO, 26, Color(0.2, 0.5, 1.0, alpha))
		draw_arc(Vector2.ZERO, 26, 0, TAU, 32, Color(0.4, 0.7, 1.0, alpha + 0.2), 2.0)

	# Score boost visual (pulsing glow)
	if boost_time > 0.0:
		var glow := 0.4 + 0.3 * sin(Time.get_ticks_msec() * 0.008)
		draw_circle(Vector2.ZERO, 22, Color(1.0, 0.85, 0.2, glow * 0.3))
