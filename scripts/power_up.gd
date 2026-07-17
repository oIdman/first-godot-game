extends Area2D

enum Type { SHIELD, SCORE_BOOST }

const COLOR_SHIELD := Color(0.3, 0.6, 1.0, 0.9)
const COLOR_BOOST := Color(1.0, 0.85, 0.2, 0.9)

var type: Type = Type.SHIELD
var _time := 0.0


func _ready():
	collision_layer = 4
	add_to_group("powerup")
	queue_redraw()


func _process(delta):
	# Gentle bobbing
	_time += delta
	position.y += sin(_time * 3.0) * delta * 20.0


func get_pu_type() -> int:
	return type


func _draw():
	var radius := 10.0
	var color := COLOR_SHIELD if type == Type.SHIELD else COLOR_BOOST
	var inner := Color(color, color.a * 0.6)

	draw_circle(Vector2.ZERO, radius, color)
	draw_circle(Vector2.ZERO, radius * 0.6, inner)

	match type:
		Type.SHIELD:
			var rect := Rect2(-4, -4, 8, 8)
			draw_rect(rect, Color(1, 1, 1, 0.8))
		Type.SCORE_BOOST:
			draw_line(Vector2(-4, -4), Vector2(4, 4), Color(1, 1, 1, 0.8), 2.0)
			draw_line(Vector2(4, -4), Vector2(-4, 4), Color(1, 1, 1, 0.8), 2.0)
