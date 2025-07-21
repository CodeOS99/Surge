extends Button

func _on_pressed() -> void:
	Globals.init()
	Globals.transition_to_scene(get_tree(), "res://Scenes/main_game.tscn")
