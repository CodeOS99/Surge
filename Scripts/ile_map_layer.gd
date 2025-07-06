extends TileMapLayer

var tree = preload("res://Scenes/spruce_tree.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for tile in get_cell_atlas_coords(Vector2i(1, 1)):
		print("hello")
		var tr = tree.instantiate()
		add_child(tr)
