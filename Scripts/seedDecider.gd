extends Node2D

@export var invGuiScene = preload("res://Scenes/inv_gui.tscn")

func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	$NoiseGenerator.seed = rng.seed
	$NoiseGenerator2.seed = rng.seed
	if Globals.invGUI:
		print("hello")
		add_child(Globals.invGUI)
	else:
		var n = invGuiScene.instantiate()
		add_child(n)
		Globals.invGUI = n
		print(n.get_child_count())

func _on_button_pressed() -> void:
	pass # Replace with function body.


func _on_held_item_mouse_entered() -> void:
	pass # Replace with function body.
