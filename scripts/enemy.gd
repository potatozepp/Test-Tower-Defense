class_name Enemy
extends Node2D

signal died(reward: int)
signal reached_base(damage: int)

@export var max_health := 32.0
@export var speed := 105.0
@export var reward := 10
@export var base_damage := 1

var health := max_health
var path: PackedVector2Array
var path_index := 1

func setup(new_path: PackedVector2Array, wave_number: int) -> void:
	path = new_path
	max_health = 28.0 + wave_number * 7.0
	health = max_health
	speed = 92.0 + wave_number * 4.0
	reward = 8 + wave_number * 2
	global_position = path[0]

func _ready() -> void:
	add_to_group("enemies")
	queue_redraw()

func _process(delta: float) -> void:
	if path.is_empty() or path_index >= path.size():
		return

	var next_point := path[path_index]
	global_position = global_position.move_toward(next_point, speed * delta)
	if global_position.distance_to(next_point) < 1.0:
		path_index += 1
		if path_index >= path.size():
			reached_base.emit(base_damage)
			queue_free()

func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0.0:
		died.emit(reward)
		queue_free()
	else:
		queue_redraw()

func _draw() -> void:
	# A circle keeps the first enemy type easy to recognize.
	draw_circle(Vector2.ZERO, 18.0, Color("e76668"))
	draw_arc(Vector2.ZERO, 18.0, 0.0, TAU, 20, Color("ffb0a8"), 2.0, true)
	var health_ratio := health / max_health
	draw_rect(Rect2(-20, -30, 40, 5), Color("243141"))
	draw_rect(Rect2(-20, -30, 40 * health_ratio, 5), Color("82dc8b"))
