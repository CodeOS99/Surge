extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	$NoiseGenerator.seed = rng.seed
	$NoiseGenerator2.seed = rng.seed


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
