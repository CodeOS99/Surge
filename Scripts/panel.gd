extends Panel

var hue := 0.0 # Value between 0.0 and 1.0

func _process(delta: float) -> void:
	hue += delta * 0.2 # Controls speed of RGB cycling
	if hue > 1.0:
		hue -= 1.0

	# Convert HSV to RGB
	var color = Color.from_hsv(hue, 1.0, 1.0)
	modulate = color
