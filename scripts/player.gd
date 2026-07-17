extends Area2D

@export var speed := 400.0

var screen_size := Vector2.ZERO
var active := false

signal hit

func _ready():
	screen_size = get_viewport_rect().size
	collision_layer = 1
	collision_mask = 2  # Detect enemies on layer 2
	area_entered.connect(_on_area_entered)
	hide()

func _process(delta):
	if not active:
		return

	var velocity := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)


func _on_area_entered(area: Area2D):
	if area.is_in_group("enemy") and active:
		hit.emit()

func _draw():
	draw_circle(Vector2.ZERO, 18, Color.GREEN_YELLOW)
	draw_circle(Vector2.ZERO, 12, Color.LIME_GREEN)
