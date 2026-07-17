extends Node2D

@export var enemy_scene: PackedScene
@export var powerup_scene: PackedScene
@export var spawn_interval := 1.5
@export var powerup_interval := 5.0

var score := 0
var game_running := false
var difficulty_timer := 0.0

@onready var player := $Player
@onready var spawn_timer := $SpawnTimer
@onready var score_label := $UI/ScoreLabel
@onready var start_button := $UI/StartButton
@onready var title_label := $UI/TitleLabel
@onready var shake_camera := $CameraShake
@onready var powerup_timer := $PowerUpTimer

func _ready():
	spawn_timer.timeout.connect(_on_spawn)
	powerup_timer.timeout.connect(_on_powerup_spawn)
	start_button.pressed.connect(_start_game)
	player.hit.connect(_on_player_hit)
	player.shield_broken.connect(_on_shield_broken)

func _process(delta):
	if not game_running:
		return

	difficulty_timer += delta
	score += delta * player.boost_multiplier
	score_label.text = "Score: %d" % score

	# Increase difficulty every 10 seconds
	if difficulty_timer >= 10.0 and spawn_timer.wait_time > 0.3:
		spawn_timer.wait_time = max(0.3, spawn_timer.wait_time - 0.15)
		difficulty_timer = 0.0

func _start_game():
	start_button.hide()
	title_label.hide()
	score_label.show()
	score_label.text = "Score: 0"

	game_running = true
	score = 0
	difficulty_timer = 0.0
	spawn_timer.wait_time = spawn_interval
	powerup_timer.wait_time = powerup_interval

	# Reset player power-ups
	player.shield_time = 0.0
	player.boost_multiplier = 1.0
	player.boost_time = 0.0

	player.position = get_viewport_rect().size / 2
	player.active = true
	player.show()
	spawn_timer.start()
	powerup_timer.start()

	SoundManager.play_start()

func _on_spawn():
	var enemy := enemy_scene.instantiate()
	var viewport_size := get_viewport_rect().size

	# Weighted enemy type selection
	var roll := randf()
	var etype: int
	if roll < 0.2:       # 20% SCOUT
		etype = 1
		enemy.speed = 300.0 + randi() % 150
	elif roll < 0.5:     # 30% TANK
		etype = 2
		enemy.speed = 60.0 + randi() % 40
	else:                # 50% NORMAL
		etype = 0
		enemy.speed = 100.0 + randi() % 150
	enemy.enemy_type = etype

	var side := randi() % 4
	match side:
		0:  # Top
			enemy.position = Vector2(randf() * viewport_size.x, -30.0)
			enemy.direction = Vector2.DOWN
		1:  # Bottom
			enemy.position = Vector2(randf() * viewport_size.x, viewport_size.y + 30.0)
			enemy.direction = Vector2.UP
		2:  # Left
			enemy.position = Vector2(-30.0, randf() * viewport_size.y)
			enemy.direction = Vector2.RIGHT
		3:  # Right
			enemy.position = Vector2(viewport_size.x + 30.0, randf() * viewport_size.y)
			enemy.direction = Vector2.LEFT

	add_child(enemy)

func _on_powerup_spawn():
	var pu := powerup_scene.instantiate()
	var vp := get_viewport_rect().size
	pu.position = Vector2(
		randf_range(40.0, vp.x - 40.0),
		randf_range(40.0, vp.y - 40.0)
	)
	pu.type = 0 if randi() % 2 == 0 else 1  # SHIELD or SCORE_BOOST
	add_child(pu)


func _on_shield_broken():
	shake_camera.shake(4.0)


func _on_player_hit():
	game_running = false
	spawn_timer.stop()
	player.active = false
	player.hide()

	# Audio-visual feedback
	SoundManager.play_hit()
	shake_camera.shake()
	await get_tree().create_timer(0.3).timeout
	SoundManager.play_game_over()

	# Show game over overlay
	var game_over := preload("res://ui/GameOver.tscn").instantiate()
	add_child(game_over)
	game_over.set_score(int(score))
	game_over.restart.connect(_restart)

func _restart():
	# Remove game over screen
	var game_overs := get_tree().get_nodes_in_group("game_over")
	for go in game_overs:
		go.queue_free()

	# Clear all enemies and powerups
	for child in get_children():
		if child.is_in_group("enemy") or child.is_in_group("powerup"):
			child.queue_free()

	_start_game()
