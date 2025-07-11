extends Node2D

func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	$NoiseGenerator.seed = rng.seed
	$NoiseGenerator2.seed = rng.seed
