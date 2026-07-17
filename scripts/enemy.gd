extends Area2D

enum Type { NORMAL, SCOUT, TANK }

## Set by main.gd on spawn
var enemy_type: Type = Type.NORMAL
var direction := Vector2.ZERO
var speed := 200.0

# Per-type visuals
var _radius := 14.0
var _color_outer := Color.DARK_RED
var _color_inner := Color.RED


func _ready():
	collision_layer = 2
	add_to_group("enemy")
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)
	_apply_type_visuals()
	queue_redraw()
	SoundManager.play_spawn()


func _apply_type_visuals():
	match enemy_type:
		Type.NORMAL:
			_radius = 10.0 + randi() % 8  # 10-17
			_color_outer = Color(0.7, 0.1, 0.1)  # dark red
			_color_inner = Color(0.9, 0.2, 0.2)  # red
		Type.SCOUT:
			_radius = 4.0 + randi() % 5   # 4-8
			_color_outer = Color(0.9, 0.5, 0.1)  # orange
			_color_inner = Color(1.0, 0.7, 0.2)  # gold
		Type.TANK:
			_radius = 22.0 + randi() % 8  # 22-29
			_color_outer = Color(0.4, 0.1, 0.5)  # purple
			_color_inner = Color(0.5, 0.2, 0.6)  # light purple


func _process(delta):
	position += direction * speed * delta


func _draw():
	draw_circle(Vector2.ZERO, _radius, _color_outer)
	draw_circle(Vector2.ZERO, _radius * 0.6, _color_inner)
