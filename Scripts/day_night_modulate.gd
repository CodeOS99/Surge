extends CanvasModulate

@export var gradient:GradientTexture1D

func _process(delta: float) -> void:
	Globals.time += delta
	var value = (sin(Globals.time)+1.0)/2.0
	self.color = gradient.gradient.sample(value)
	if (0.0 < value) and (value < 0.1):
		Globals.player.get_in_battle()
