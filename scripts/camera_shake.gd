extends Camera2D

## Screen shake on player hit using Tween.

@export var shake_intensity := 8.0
@export var shake_duration := 0.25
@export var shake_fade := true

var _trauma := 0.0
var _tween: Tween


func shake(custom_intensity: float = -1.0) -> void:
	var intensity := custom_intensity if custom_intensity > 0.0 else shake_intensity
	
	if _tween and _tween.is_valid():
		_tween.kill()
	
	offset = Vector2.ZERO
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_SINE)
	
	if shake_fade:
		# Full intensity at start, taper to zero
		var steps := 6
		for i in steps:
			var t := float(i) / steps
			var decay := 1.0 - t
			var shake_vec := Vector2(
				randf_range(-intensity, intensity),
				randf_range(-intensity, intensity)
			) * decay
			_tween.tween_property(self, "offset", shake_vec, shake_duration / steps)
		
		_tween.tween_property(self, "offset", Vector2.ZERO, 0.05)
	else:
		_tween.tween_property(self, "offset", Vector2.ZERO, shake_duration)
