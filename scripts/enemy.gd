extends Area2D

@export var speed := 200.0

var direction := Vector2.ZERO
var _rng := RandomNumberGenerator.new()

func _ready():
	collision_layer = 2
	add_to_group("enemy")
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)
	queue_redraw()
	SoundManager.play_spawn()

func _process(delta):
	position += direction * speed * delta

func _draw():
	var radius := 4.0 + _rng.randf_range(0.0, 12.0)
	draw_circle(Vector2.ZERO, radius, Color.DARK_RED)
	draw_circle(Vector2.ZERO, radius * 0.6, Color.RED)
