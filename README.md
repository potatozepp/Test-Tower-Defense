# Learning Tower Defense — Version 0.1

A small, playable Godot 4.x tower-defense prototype built to teach the basics without external assets or complex architecture.

## Run it

1. Open this folder in **Godot 4.x**.
2. Press **F6** (or click Run Project).
3. Left-click open ground to place Cannon towers for `$40`.
4. Stop the geometric enemies before they reach the base.

## Included in Version 0.1

- A 1920×1080 2D map with a fixed path and player base.
- Circular enemies that move between path points.
- One Cannon tower that finds the nearest enemy in its range and fires projectiles.
- Damage, enemy rewards, base health, game over, waves, and a compact HUD.

## Learning map

- `scripts/main.gd` owns the game state, map drawing, placement checks, and HUD updates.
- `scripts/enemy.gd` demonstrates a Node2D moving through a `PackedVector2Array` and emitting signals.
- `scripts/tower.gd` demonstrates group-based targeting with the `enemies` group.
- `scripts/projectile.gd` follows a target and applies damage.
- `scripts/wave_manager.gd` is a small child Node that controls spawn timing and wave completion.

The visuals are drawn in each node's `_draw()` function. This means the prototype needs no sprite files while still making enemy, tower, range, projectile, path, and base gameplay readable.
