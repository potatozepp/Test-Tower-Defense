class_name Projectile
extends Node2D

var target: Enemy
var damage := 12.0
var speed := 700.0

func setup(new_target: Enemy, new_damage: float) -> void:
	target = new_target
	damage = new_damage

func _process(delta: float) -> void:
	if not is_instance_valid(target):
		queue_free()
		return

	global_position = global_position.move_toward(target.global_position, speed * delta)
	if global_position.distance_to(target.global_position) < 10.0:
		target.take_damage(damage)
		queue_free()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 5.0, Color("ffe28a"))
