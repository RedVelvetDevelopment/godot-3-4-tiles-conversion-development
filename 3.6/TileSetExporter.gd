extends Node
class_name TileSetExporter

func _ready():
	var tilesets = find_tilesets_in_res()
	

func _create_dict(path:String, tileset:TileSet):
	var out:Array
	var atlas_count = tileset.get_tiles_ids()
	for atlas in atlas_count:
		var dict:Dictionary = {
			
		}
	

func find_tilesets_in_res() -> Array:
	var results = []
	_scan_dir("res://", results)
	return results


func _scan_dir(path: String, results: Array) -> void:
	var dir = Directory.new()
	if dir.open(path) != OK:
		push_warning("Could not open directory: " + path)
		return

	dir.list_dir_begin(true, true)  # Skip hidden files and return relative paths
	var file_name = dir.get_next()

	while file_name != "":
		var full_path = path.plus_file(file_name)

		if dir.current_is_dir():
			_scan_dir(full_path, results)
		else:
			if file_name.ends_with(".tres") or file_name.ends_with(".res") or file_name.ends_with(".tileset"):
				var res = ResourceLoader.load(full_path)
				if res and res is TileSet:
					results.append({
						"path": full_path,
						"resource": res
					})
		file_name = dir.get_next()

	dir.list_dir_end()
