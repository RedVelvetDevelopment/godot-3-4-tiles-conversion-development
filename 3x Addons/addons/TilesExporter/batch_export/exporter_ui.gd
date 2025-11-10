tool
extends WindowDialog

onready var event_log = $"%EventLog"
onready var convert_btn = $"%convert_button"

const TileMapExporter = preload("../tilemap/tilemap_exporter.gd")
const TileSetExporter = preload("../tileset/tileset_exporter.gd")

## Key is Object, Value is the string path (could be inside .tscn)
var tilemaps:Dictionary = {}
var tilesets:Dictionary = {} #Load will actually give use a shared ref, we want unique ones
var retry_counter = 0

func _ready():
	scan()
	convert_btn.connect("pressed",self,"export_btn")

func scan():
	tilemaps = {}
	tilesets = {}
	event_log.text = "Scanning....\n"
	var scenes = get_all_files("res://","tscn")
	var discovered_tilesets:Dictionary
	
	for scene in scenes:
		var tile_maps = search_tscn_file(scene)
		for tilemap in tile_maps:
			tilemap = tilemap as TileMap
			if tilemap.tile_set:
				#This could get set twice, but the resource path should be the same.
				tilesets[tilemap.tile_set] = tilemap.tile_set.resource_path
			tilemaps[tilemap] = scene
			
		#exporter.output_path = scene
	event_log.text += ("Found %d tilemaps\n" % tilemaps.size())
	event_log.text += ("Found %d tilesets\n" % tilesets.size())

func export_btn():
	var map_exporter:TileMapExporter = TileMapExporter.new()
	var set_exporter:TileSetExporter = TileSetExporter.new()
	for tilemap in tilemaps:
		var path:String = tilemaps[tilemap]
		var data = map_exporter.process_tilemap(tilemap)
		event_log.text += ("Exporting tilemap %s\n" % path)
		write_data(path.get_base_dir(),tilemap.name,data,"tilemap")
	
	for tileset in tilesets:
		var path:String = tilesets[tileset]
		var data = set_exporter.process_tileset(tileset)
		event_log.text += ("Exporting tileset %s\n" % path)
		write_data(path.get_base_dir(),path.get_file(), data, "tileset")
	pass

func write_data(path:String,file_name:String,dict:Dictionary, fallback:String, retry_attempt:bool = false):
	var json = JSON.print(dict, "\t")
	#print(file_name)
	var file_path = path + file_name + ".json"
	var file = File.new()
	var error = file.open(file_path, File.WRITE)
	if error == OK:
		file.store_string(json)
		file.close()
		event_log.text += ("%s Exported\n" % file_path)
		#print("File saved to:", file_path)
	else:
		if not retry_attempt:
			event_log.text += ("Could not save: %s for writing, attempting fallback...\n" % file_path)
			retry_counter += 1
			write_data(path,fallback+"_"+str(retry_counter),dict,fallback,true)
		else:
			event_log.text += "Retry attempt failed\n"
	pass

func _exit_tree():
	for tilemap in tilemaps:
		tilemap.queue_free()
	pass

func search_tscn_file(path:String) -> Array:
	event_log.text += "Opening TSCN: " + path + "\n"
	var results = []
	var scene:PackedScene = load(path)
	var scene_state:SceneState = scene.get_state()
	for node_id in scene_state.get_node_count():
		var type =  scene_state.get_node_type(node_id)
		if type == "TileMap":
			event_log.text += "Node of type: " + scene_state.get_node_type(node_id) + " found!\n"
			var runtime_tilemap:TileMap = TileMap.new()
			runtime_tilemap.name = scene_state.get_node_name(node_id)
			for node_prop_id in scene_state.get_node_property_count(node_id):
				var prop_name = scene_state.get_node_property_name(node_id,node_prop_id)
				var prop_value = scene_state.get_node_property_value(node_id,node_prop_id)
				var prop_type = typeof(prop_value)
				if prop_name != "script":
					runtime_tilemap.set(prop_name,prop_value)
			results.append(runtime_tilemap)
	return results

func get_unique_tilesets(tile_maps:Array) -> Array:
	return []

func get_all_files(path: String, file_ext := "", files := []):
	var dir = Directory.new()

	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)

		var file_name = dir.get_next()

		while file_name != "":
			if dir.current_is_dir():
				files = get_all_files(dir.get_current_dir().plus_file(file_name), file_ext, files)
			else:
				if file_ext and file_name.get_extension() != file_ext:
					file_name = dir.get_next()
					continue
				var full_path = dir.get_current_dir().plus_file(file_name)
				files.append(full_path)
				#event_log.text += "TSCN found: " + full_path + "\n"

			file_name = dir.get_next()
	else:
		event_log.text = ("An error occurred when trying to access %s." % path)

	return files
