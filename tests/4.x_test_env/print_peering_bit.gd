extends TileMapLayer

func _ready() -> void:
	var cells := get_used_cells()
	for cell in cells:
		var atlas_coords = get_cell_atlas_coords(cell)
		var source_id = get_cell_source_id(cell)
		var source = tile_set.get_source(source_id)
		for indx in tile_set.get_terrain_sets_count():
			for ter in tile_set.get_terrains_count(indx):
				var terrain_name = tile_set.get_terrain_name(indx, ter)
				print("terrain_name: ", terrain_name)
		var tile_data = self.get_cell_tile_data(cell)
		tile_data.terrain
		
