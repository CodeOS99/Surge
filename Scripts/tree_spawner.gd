extends Node2D

var tree = preload("res://Scenes/spruce_tree.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func spawnTrees():
	for tile in $"../TileMapLayer".get_used_cells_by_id(0, Vector2i(1,1), 0):
		var world_pos = $"../TileMapLayer".map_to_local(tile)
		var tr = tree.instantiate()
		add_child(tr)
		tr.position = world_pos
		print("sdfidsin")
