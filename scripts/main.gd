extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval := 1.5

var score := 0
var game_running := false
var difficulty_timer := 0.0

@onready var player := $Player
@onready var spawn_timer := $SpawnTimer
@onready var score_label := $UI/ScoreLabel
@onready var start_button := $UI/StartButton
@onready var title_label := $UI/TitleLabel
@onready var shake_camera := $CameraShake

func _ready():
	spawn_timer.timeout.connect(_on_spawn)
	start_button.pressed.connect(_start_game)
	player.hit.connect(_on_player_hit)

func _process(delta):
	if not game_running:
		return

	difficulty_timer += delta
	score += delta
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

	player.position = get_viewport_rect().size / 2
	player.active = true
	player.show()
	spawn_timer.start()

	SoundManager.play_start()

func _on_spawn():
	var enemy := enemy_scene.instantiate()
	var viewport_size := get_viewport_rect().size

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

	enemy.speed = 100.0 + randi() % 200
	add_child(enemy)

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

	# Clear all enemies
	for child in get_children():
		if child.is_in_group("enemy"):
			child.queue_free()

	_start_game()
