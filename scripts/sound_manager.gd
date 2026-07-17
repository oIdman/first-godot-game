extends Node

## Procedural sound manager (autoload).
## Generates all audio via code — no external audio files needed.

const SAMPLE_RATE := 22050
const VOLUME_DB := -6.0


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS


# ---------------------------------------------------------------------------
#  Public API
# ---------------------------------------------------------------------------

func play_hit() -> void:
	var wav := _generate_tone(120.0, 0.25, 0.6, _envelope_fast_decay)
	_play(wav)


func play_game_over() -> void:
	var wav := _generate_tone(80.0, 0.8, 0.7, _envelope_slow_decay)
	_play(wav)


func play_spawn() -> void:
	var wav := _generate_tone(440.0, 0.12, 0.3, _envelope_fast_decay)
	_play(wav)


func play_start() -> void:
	var wav := _generate_tone(523.0, 0.1, 0.4, _envelope_fast_decay)
	_play(wav)
	
	# Wait a tiny bit and play a second note (cheap "coin" effect)
	await get_tree().create_timer(0.08).timeout
	var wav2 := _generate_tone(659.0, 0.1, 0.4, _envelope_fast_decay)
	_play(wav2)


# ---------------------------------------------------------------------------
#  Internal
# ---------------------------------------------------------------------------

func _generate_tone(
	frequency: float,
	duration: float,
	volume: float,
	envelope_func: Callable,
) -> AudioStreamWAV:
	var num_samples := int(SAMPLE_RATE * duration)
	var data := PackedByteArray()
	data.resize(num_samples * 2)  # 16-bit mono

	var amp := volume * 0.6
	for i in num_samples:
		var t := float(i) / SAMPLE_RATE
		var env := envelope_func.call(t, duration)
		var sample := sin(2.0 * PI * frequency * t) * amp * env
		var s16 := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, s16)

	var wav := AudioStreamWAV.new()
	wav.data = data
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	return wav


static func _envelope_fast_decay(t: float, dur: float) -> float:
	# Sharp attack, fast exponential decay
	var n := t / dur
	return exp(-6.0 * n)


static func _envelope_slow_decay(t: float, dur: float) -> float:
	var n := t / dur
	return exp(-3.0 * n)


func _play(stream: AudioStreamWAV) -> void:
	var player := AudioStreamPlayer2D.new()
	player.stream = stream
	player.volume_db = VOLUME_DB
	add_child(player)
	player.play()
	# Auto-cleanup when done
	await player.finished
	player.queue_free()
