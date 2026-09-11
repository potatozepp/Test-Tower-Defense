class_name Tower
extends Node2D

const PROJECTILE_SCENE := preload("res://scenes/projectile.tscn")

@export var attack_range := 185.0
@export var damage := 14.0
@export var shots_per_second := 1.15

var cooldown := 0.0

func _ready() -> void:
	add_to_group("towers")

func _process(delta: float) -> void:
	cooldown = maxf(cooldown - delta, 0.0)
	if cooldown > 0.0:
		return

	var target := find_nearest_enemy()
	if target != null:
		shoot(target)
		cooldown = 1.0 / shots_per_second

func find_nearest_enemy() -> Enemy:
	var nearest: Enemy
	var nearest_distance := attack_range
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy == null:
			continue
		var distance := global_position.distance_to(enemy.global_position)
		if distance < nearest_distance:
			nearest = enemy
			nearest_distance = distance
	return nearest

func shoot(target: Enemy) -> void:
	var projectile := PROJECTILE_SCENE.instantiate() as Projectile
	projectile.global_position = global_position
	projectile.setup(target, damage)
	get_parent().add_child(projectile)

func _draw() -> void:
	# The transparent circle teaches that range is a gameplay property, not a sprite.
	draw_circle(Vector2.ZERO, attack_range, Color(0.25, 0.7, 1.0, 0.055))
	draw_arc(Vector2.ZERO, attack_range, 0.0, TAU, 64, Color(0.3, 0.72, 0.98, 0.3), 1.5, true)
	draw_circle(Vector2.ZERO, 25.0, Color("3979b8"))
	draw_circle(Vector2.ZERO, 17.0, Color("70b7eb"))
	draw_circle(Vector2.ZERO, 7.0, Color("e8f6ff"))
