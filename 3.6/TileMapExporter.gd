extends Node
class_name TileMapExporter

var tilemaps:Array = []
var tilesets:Array = []

func _ready():
	_collect_tilemaps(get_tree().root)
	var dicts = process_tilemaps()
	for dict in dicts:
		_write_file(
			"C:\\Users\\stran\\Projects\\godot-3-4-tiles-conversion\\",
			dict["name"], 
			dict
		)

	


func _write_file(path:String, name:String, dict:Dictionary):
	var json = JSON.print(dict, "\t")

	var file_path = path + name +".json"
	var file = File.new()
	var error = file.open(file_path, File.WRITE)
	if error == OK:
		file.store_string(json)
		file.close()
		print("File saved to:", file_path)
	else:
		push_error("Could not open file for writing!")


func _collect_tilemaps(start:Node):
	for child in start.get_children():
		if child is TileMap: 
			tilemaps.append(child)
		
		if child.get_children().size() > 0:
			_collect_tilemaps(child)

func process_tilemaps():
	var out:Array = []
	for tilemap in tilemaps:
		var tileset = tilemap.tile_set
		if not tilesets.find(tileset):
			tilesets.append(tileset)
		
		var atlas_path = tileset.tile_get_texture(0).resource_path
		var tile_ids = tileset.get_tiles_ids()
		var tile_regions:Array = []
		for id in tile_ids:
			tile_regions.append(tileset.tile_get_region(id))
		
		

		var dict:Dictionary = {
			"name":tilemap.name,
			"atlas_path":atlas_path,
			"tile_ids":tile_ids,
			"tile_regions":tile_regions,
			
			"cell_size":tilemap.cell_size,
			"cell_quadrant_size":tilemap.cell_quadrant_size,
			"cell_custom_transform":tilemap.cell_custom_transform,
			"cell_half_offest":tilemap.cell_half_offset,
			"cell_tile_origin":tilemap.cell_tile_origin,
			"cell_y_sort":tilemap.cell_y_sort,
			"show_collision":tilemap.show_collision,
			"compatibility_mode":tilemap.compatibility_mode,
			"centered_textures":tilemap.centered_textures,
			"cell_clip_uv":tilemap.cell_clip_uv,
			"collision_use_parent":tilemap.collision_use_parent,
			"collision_use_kinematic":tilemap.collision_use_kinematic,
			"collision_friction":tilemap.collision_friction,
			
			"cells":[]
		}

		var used_cells:Array = tilemap.get_used_cells()
		for indx in used_cells.size():
			var region = tilemap.get_cell_autotile_coord(used_cells[indx].x, used_cells[indx].y)
			var transposed = tilemap.is_cell_transposed(used_cells[indx].x, used_cells[indx].y)
			var x_flipped = tilemap.is_cell_x_flipped(used_cells[indx].x, used_cells[indx].y)
			var y_flipped = tilemap.is_cell_y_flipped(used_cells[indx].x, used_cells[indx].y)
			dict["cells"].append({
				"x":used_cells[indx].x,
				"y":used_cells[indx].y,
				"id":region,
				"transposed":transposed,
				"x_flipped":x_flipped,
				"y_flipped":y_flipped
			})
		out.append(dict)
		
	return out
