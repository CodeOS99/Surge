extends Node2D

@export var goblin_scene: PackedScene
@export var skeleton_scene: PackedScene
@export var zombie_scene: PackedScene

func _ready():
	spawn_wave(Globals.wave_number)
	Globals.wave_number += 1

func spawn_wave(wave):
	var enemy_count = clamp(wave, 1, 20)  # Optional max limit
	for i in range(enemy_count):
		var enemy_scene = get_random_enemy(wave)
		var instance = enemy_scene.instantiate()
		
		# Procedural position (random near center)
		var pos = get_random_spawn_position()
		instance.position = pos

		# Procedural health
		if instance.has_method("set_health"):
			var base_health = 50
			var wave_multiplier = 1.2 + (wave * 0.3)
			instance.set_health(int(base_health * wave_multiplier))

		add_child(instance)

func get_random_enemy(wave):
	if wave == 1:
		return goblin_scene
	elif wave == 2:
		return [skeleton_scene, zombie_scene][randi() % 2]
	else:
		var pool = [goblin_scene, skeleton_scene, zombie_scene]
		return pool[randi() % pool.size()]

func get_random_spawn_position() -> Vector2:
	var center = Vector2(320, 352)  # Assume center of screen or game world
	var radius = 100 + randf_range(0, 296-100)
	var angle = randf_range(0, TAU)
	return center + Vector2(cos(angle), sin(angle)) * radius
