class_name Globals extends Node

static var player: CharacterBody2D = null
static var invGUI
static var time:float = 0.0
static var wave_number: int = 1

static func transition_to_scene(tree: SceneTree, target_scene_path: String):
	if invGUI:
		# IMPORTANT: Detach invGUI from its current parent BEFORE changing scenes
		# Check if it has a parent before trying to remove it
		if invGUI.get_parent():
			invGUI.get_parent().remove_child(invGUI)
			print("invGUI detached from old scene.")
		else:
			print("invGUI has no parent to detach from.")
	else:
		print("No invGUI to detach.")

	# Change the scene
	# Assuming you're using SceneTree.change_scene_to_file()
	tree.change_scene_to_file(target_scene_path)
