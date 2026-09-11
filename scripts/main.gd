extends Node2D

const ENEMY_SCENE := preload("res://scenes/enemy.tscn")
const TOWER_SCENE := preload("res://scenes/tower.tscn")
const WAVE_MANAGER_SCRIPT := preload("res://scripts/wave_manager.gd")

const TOWER_COST := 40
const STARTING_MONEY := 100
const STARTING_BASE_HEALTH := 20

var path := PackedVector2Array([
	Vector2(-40, 330), Vector2(280, 330), Vector2(470, 520),
	Vector2(760, 520), Vector2(930, 310), Vector2(1240, 310),
	Vector2(1440, 650), Vector2(1700, 650), Vector2(1810, 830),
])
var money := STARTING_MONEY
var base_health := STARTING_BASE_HEALTH
var game_over := false
var wave_manager: WaveManager

@onready var money_label: Label = $HUD/TopPanel/MoneyLabel
@onready var base_label: Label = $HUD/TopPanel/BaseLabel
@onready var wave_label: Label = $HUD/TopPanel/WaveLabel
@onready var message_label: Label = $HUD/MessageLabel

func _ready() -> void:
	wave_manager = WAVE_MANAGER_SCRIPT.new()
	add_child(wave_manager)
	wave_manager.enemy_requested.connect(_spawn_enemy)
	wave_manager.wave_started.connect(_on_wave_started)
	wave_manager.wave_completed.connect(_on_wave_completed)
	update_hud()
	queue_redraw()
	# A short pause gives the player time to place the first tower.
	await get_tree().create_timer(2.0).timeout
	if not game_over:
		wave_manager.start_next_wave()

func _unhandled_input(event: InputEvent) -> void:
	if game_over or not event is InputEventMouseButton:
		return
	if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		try_place_tower(get_global_mouse_position())

func try_place_tower(location: Vector2) -> void:
	if money < TOWER_COST:
		show_message("Not enough money for a Cannon.")
		return
	if not is_valid_tower_location(location):
		show_message("Place towers on open ground, away from the path.")
		return

	var tower := TOWER_SCENE.instantiate() as Tower
	tower.global_position = location
	add_child(tower)
	money -= TOWER_COST
	show_message("Cannon placed!")
	update_hud()

func is_valid_tower_location(location: Vector2) -> bool:
	if location.x < 45.0 or location.x > 1875.0 or location.y < 245.0 or location.y > 1035.0:
		return false
	if location.distance_to(path[path.size() - 1]) < 85.0 or distance_to_path(location) < 58.0:
		return false
	for tower in get_tree().get_nodes_in_group("towers"):
		if location.distance_to(tower.global_position) < 65.0:
			return false
	return true

func distance_to_path(point: Vector2) -> float:
	var closest_distance := INF
	for index in range(path.size() - 1):
		var start := path[index]
		var finish := path[index + 1]
		var segment := finish - start
		var progress := clampf((point - start).dot(segment) / segment.length_squared(), 0.0, 1.0)
		closest_distance = minf(closest_distance, point.distance_to(start + segment * progress))
	return closest_distance

func _spawn_enemy(wave_number: int) -> void:
	if game_over:
		return
	var enemy := ENEMY_SCENE.instantiate() as Enemy
	add_child(enemy)
	enemy.setup(path, wave_number)
	enemy.died.connect(_on_enemy_died)
	enemy.reached_base.connect(_on_enemy_reached_base)

func _on_enemy_died(reward: int) -> void:
	money += reward
	wave_manager.enemy_left_playfield()
	update_hud()

func _on_enemy_reached_base(damage: int) -> void:
	base_health = max(base_health - damage, 0)
	wave_manager.enemy_left_playfield()
	update_hud()
	if base_health <= 0:
		end_game()

func _on_wave_started(wave_number: int) -> void:
	show_message("Wave %d incoming" % wave_number)
	update_hud()

func _on_wave_completed(wave_number: int) -> void:
	if game_over:
		return
	money += 20
	show_message("Wave %d cleared! +$20" % wave_number)
	update_hud()
	await get_tree().create_timer(3.0).timeout
	if not game_over:
		wave_manager.start_next_wave()

func end_game() -> void:
	game_over = true
	message_label.text = "GAME OVER — reload the scene to try again"
	wave_label.text = "The base was overrun"

func show_message(new_message: String) -> void:
	message_label.text = new_message

func update_hud() -> void:
	money_label.text = "Money: $%d" % money
	base_label.text = "Base: %d" % base_health
	if not game_over:
		var state := "Prepare defenses" if wave_manager == null or wave_manager.waiting_for_next_wave else "Enemies approaching"
		var number = 1 if wave_manager == null else max(wave_manager.current_wave, 1)
		wave_label.text = "Wave %d  •  %s" % [number, state]

func _draw() -> void:
	# Map drawing stays in one place so the prototype needs no art assets.
	draw_rect(Rect2(0, 225, 1920, 855), Color("102035"))
	draw_polyline(path, Color("4b5768"), 74.0, true)
	draw_polyline(path, Color("7f8ca0"), 4.0, true)
	for point in path:
		draw_circle(point, 5.0, Color("9caabd"))

	var base_position := path[path.size() - 1]
	draw_circle(base_position, 53.0, Color("204d62"))
	draw_circle(base_position, 39.0, Color("48c6b4"))
	draw_string(ThemeDB.fallback_font, base_position + Vector2(-29, 7), "BASE", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("07141e"))
