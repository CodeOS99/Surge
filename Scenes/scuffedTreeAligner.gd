extends TileMapLayer




func _on_noise_generator_2_generation_finished() -> void:
	self.tile_set.tile_size.y = 32
	self.tile_set.tile_size.y = 16
