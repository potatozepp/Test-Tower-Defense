class_name WaveManager
extends Node

signal enemy_requested(wave_number: int)
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)

var current_wave := 0
var enemies_to_spawn := 0
var enemies_alive := 0
var spawn_delay := 0.65
var spawn_timer := 0.0
var waiting_for_next_wave := true

func start_next_wave() -> void:
	current_wave += 1
	enemies_to_spawn = 5 + current_wave * 2
	enemies_alive = 0
	spawn_timer = 0.5
	waiting_for_next_wave = false
	wave_started.emit(current_wave)

func _process(delta: float) -> void:
	if waiting_for_next_wave:
		return
	if enemies_to_spawn > 0:
		spawn_timer -= delta
		if spawn_timer <= 0.0:
			enemies_to_spawn -= 1
			enemies_alive += 1
			enemy_requested.emit(current_wave)
			spawn_timer = spawn_delay
	elif enemies_alive == 0:
		waiting_for_next_wave = true
		wave_completed.emit(current_wave)

func enemy_left_playfield() -> void:
	enemies_alive = max(enemies_alive - 1, 0)
