@tool
extends RefCounted

class MyTileSetData:
	var name:String
	var res_path:String
	var atlases
	var tile_data
	static func from(data:Dictionary) -> MyTileSetData:
		var out:MyTileSetData = MyTileSetData.new()
		out.name = data["name"]
		out.res_path = data["resource_path"]
		print(data["name"], " -> atlas_debug: ", data["atlases"])
		var atlases = data["atlases"]
		atlases = atlases as Array[String] 
		out.atlases = atlases
		for tile_data in data["tile_data"]:
			tile_data = tile_data as Array[MyTileData]
			out.tile_data.append(MyTileData.from(tile_data))
		return out

class MyTileData:
	var id:int
	var coord:Vector2i
	var tile_mode:TileMode
	var tile_config:TileConfig
	static func from(data:Dictionary) -> MyTileData:
		var out = MyTileData.new()
		out.id = data["id"]
		out.coord = Vector2i(data["coord"]["x"], data["coord"]["y"])
		match data["tile_mode"]:
			0: out.tile_mode = TileMode.Single
			1: out.tile_mode = TileMode.Auto
			2: out.tile_mode = TileMode.Atlas
		match out.tile_mode:
			TileMode.Single: out.tile_config = SingleTileConfig.from(data["single_tile"])
			TileMode.Auto: out.tile_config = AutoTileConfig.from(data["autotile"])
			TileMode.Atlas: out.tile_config = AtlasTileConfig.from(data["atlas_tile"])
		return out

class TileConfig:
	var name:String
	var collision_shapes:Array[CollisionShape]
	var material_path:String
	var modulate:Color
	var light_occluder:Array[LightOccluder]
	var light_occluder_offs:Vector2i
	var nav_poly:Array[NavigationPolygon]
	var nav_poly_offs:Vector2i
	var region:Rect2i
	var region_size:Vector2i
	var region_position:Vector2i
	var normal_map_path:String
	var texture_path:String
	var texture_offs:Vector2i
	var z_index:int
	static func from(data:Dictionary) -> TileConfig:
		var out =  TileConfig.new()
		out.name = data["name"]
		for shape in data["collision_shapes"]:
			out.collision_shapes.append(CollisionShape.from(shape))
		out.modulate = Util._color_from_arr(data["modulate"])
		for occluder in data["light_occluder"]:
			out.light_occluder.append(LightOccluder.from(occluder))
		out.light_occluder_offs = Util._v2_from_arr(data["light_occluder_offs"])
		for nav in data["nav_poly"]:
			var real_nav := NavigationPolygon.new()
			real_nav.add_outline(Util._packed_v2_from_arr(nav))
			out.nav_poly.append(real_nav)
		out.nav_poly_offs = data["nav_polygon_offs"]
		out.region = Util._rec2i_from_arr(data["region"])
		out.region_size = Util._v2_from_arr(data["region_size"])
		out.region_position = Util._v2_from_arr(data["region_position"])
		out.normal_map_path = data["normal_map_path"]
		out.texture_path = data["texture_path"]
		out.texture_offs = Util._v2_from_arr(data["texture_offs"])
		out.z_index = data["z_index"]
		return out
		

class AutoTileConfig extends TileConfig:
	var bitmask:Dictionary[Array, int]
	var bitmask_mode:int
	var fallback_mode:int
	var subtile_size:Vector2i
	var subtile_count:Vector2i
	var subtile_priority:int
	var spacing:int
	static func from(data:Dictionary) -> AtlasTileConfig:
		var out := super(data) as AtlasTileConfig
		out.bitmask = data["bitmask"]
		out.bitmask_mode = data["bitmask_mode"]
		out.fallback_mode = data["fallback_mode"]
		out.subtile_size = Util._v2_from_arr(data["subtile_size"])
		out.subtile_count = Util._v2_from_arr(data["subtile_count"])
		out.subtile_priority = data["subtile_priority"]
		out.spacing = data["spacing"]
		return out

class SingleTileConfig extends TileConfig:
	static func from(data:Dictionary) -> SingleTileConfig:
		return super(data) as SingleTileConfig

class AtlasTileConfig extends TileConfig:
	var fallback_mode:int
	var subtile_size:Vector2i
	var subtile_count:Vector2i
	var subtile_priority:int
	var spacing:int
	static func from(data:Dictionary) -> AtlasTileConfig:
		var out := super(data) as AtlasTileConfig
		out.fallback_mode = data["fallback_mode"]
		out.subtile_size = Util._v2_from_arr(data["subtile_size"])
		out.subtile_count = Util._v2_from_arr(data["subtile_count"])
		out.subtile_priority = data["subtile_priority"]
		out.spacing = data["spacing"]
		return out

class LightOccluder:
	var closed:bool
	var mode:int
	var pool:PackedVector2Array
	static func from(data:Dictionary) -> LightOccluder:
		var out := LightOccluder.new()
		out.closed = data["closed"]
		out.mode = data["mode"]
		out.pool = Util._packed_v2_from_arr(data["pool"])
		return out
	func to() -> OccluderPolygon2D:
		var out := OccluderPolygon2D.new()
		out.closed = self.closed
		out.cull_mode = self.mode
		out.polygon = self.pool
		return out
	
class CollisionShape:
	var autotile_coord:Vector2
	var one_way:bool
	var one_way_margin:int
	var shape:PackedVector2Array
	static func from(data:Dictionary) -> CollisionShape:
		var out := CollisionShape.new()
		out.autotile_coord = Util._v2_from_arr(data["autotile_coord"])
		out.one_way = data["one_way"]
		out.one_way_margin = data["one_way_margin"]
		out.shape = Util._packed_v2_from_arr(data["shape"])
		return out

class Util:
	static func _rec2i_from_arr(arr:Array[int]) -> Rect2i:
		return Rect2i(arr[0], arr[1], arr[2], arr[3])
	static func _v2_from_arr(arr:Array[int]) -> Vector2i:
		return Vector2i(arr[0], arr[1])
	static func _packed_v2_from_arr(arr:Array[Array]) -> PackedVector2Array:
		var tmp:Array[Vector2i]
		for a in arr: tmp.append(_v2_from_arr(a))
		return PackedVector2Array(tmp)
	static func _color_from_arr(arr:Array[int]) -> Color:
		return Color(arr[0], arr[1], arr[2], arr[3])

func create_tileset_from_classes(data:Dictionary) -> TileSet:
	## BEHOLD GOD
	var tileset_data = MyTileSetData.from(data)
	
	var out := TileSet.new()
	var sources:Dictionary[String, TileSetAtlasSource]
	out.add_navigation_layer(0)
	out.add_occlusion_layer(0)
	out.add_physics_layer(0)
	out.add_terrain_set(0)
	out.add_terrain(0,0)
	
	for atlas_path in tileset_data.atlases:
		var source := TileSetAtlasSource.new()
		source.texture = load(atlas_path)
		sources[atlas_path] = source
		out.add_source(source)
		
	for tile_data in tileset_data.tile_data:
		tile_data = tile_data as MyTileData
		if tile_data.tile_mode == TileMode.Single:
			var tile_config:SingleTileConfig = tile_data.tile_config
			var source := sources[tile_config.texture_path]
			source.texture_region_size = tile_config.region_size
			if tile_data.coord.x > source.texture.get_size().x \
			or tile_data.coord.y > source.texture.get_size().y:
				continue
			
			var atlas_coord = tile_data.coord / tile_config.region_size
			source.create_tile(atlas_coord)
			var tile:TileData = source.get_tile_data(atlas_coord, 0)
			for indx in tile_config.collision_shapes.size()-1:
				var collision_shape = tile_config.collision_shapes[indx]
				_create_collision_from_shape(tile, collision_shape, indx)
			for nav in tile_config.nav_poly:
				tile.set_navigation_polygon(0, nav)
			for indx in tile_config.light_occluder.size()-1:
				tile.set_occluder_polygon(0, indx, tile_config.light_occluder[indx].to())
			
		if tile_data.tile_mode == TileMode.Auto:
			var tile_config:AutoTileConfig = tile_data.tile_config
			var source := sources[tile_config.texture_path]
			source.texture_region_size = tile_config.region_size
			if tile_data.coord.x > source.texture.get_size().x \
			or tile_data.coord.y > source.texture.get_size().y:
				continue
			for x in tile_config.subtile_count.x:
				for y in tile_config.subtile_count.y:
					var atlas_coord = Vector2i(x,y)
					source.create_tile(atlas_coord)
					var tile:TileData = source.get_tile_data(atlas_coord, 0)
					tile.terrain_set = 0
					tile.terrain = 0
					var decoded = _decode_bitmask(tile_config.bitmask[[x,y]])
					for bit in decoded:
						tile.set_terrain_peering_bit(_convert_peeringbits(bit), 0)
					for indx in tile_config.collision_shapes.size()-1:
						var collision_shape = tile_config.collision_shapes[indx]
						_create_collision_from_shape(tile, collision_shape, indx)
					for nav in tile_config.nav_poly:
						tile.set_navigation_polygon(0, nav)
					for indx in tile_config.light_occluder.size()-1:
						tile.set_occluder_polygon(0, indx, tile_config.light_occluder[indx].to())
				
		if tile_data.tile_mode == TileMode.Atlas:
			var tile_config:AtlasTileConfig = tile_data.tile_config
			var source := sources[tile_config.texture_path]
			source.texture_region_size = tile_config.region_size
			if tile_data.coord.x > source.texture.get_size().x \
			or tile_data.coord.y > source.texture.get_size().y:
				continue
			for x in tile_config.subtile_count.x:
				for y in tile_config.subtile_count.y:
					var atlas_coord = Vector2i(x,y)
					source.create_tile(atlas_coord)
					var tile:TileData = source.get_tile_data(atlas_coord, 0)
					for indx in tile_config.collision_shapes.size()-1:
						var collision_shape = tile_config.collision_shapes[indx]
						_create_collision_from_shape(tile, collision_shape, indx)
					for nav in tile_config.nav_poly:
						tile.set_navigation_polygon(0, nav)
					for indx in tile_config.light_occluder.size()-1:
						tile.set_occluder_polygon(0, indx, tile_config.light_occluder[indx].to())	
	return out

func overwrite_save(old_tileset_path:String, new_tileset:TileSet):
	ResourceSaver.save(new_tileset, old_tileset_path)

func backup_and_save(old_tileset_path:String, new_tileset:TileSet):
	var swap_path = old_tileset_path
	var swap_name = swap_path.get_file()
	var old = load(swap_path)
	var rid = old.get_rid()
	print("old rid: ", rid)
	var backup_dir = _create_dir("res://", "converted_tileset_backup")
	old.take_over_path(backup_dir+swap_name)
	ResourceSaver.save(old)
	ResourceSaver.save(new_tileset, swap_path)
	ResourceSaver.set_uid(swap_path, rid.get_id())

func load_data_from_file(file_path:String) -> Dictionary:
	#print("load_data_from_file")
	var text := FileAccess.get_file_as_string(file_path)
	if text.is_empty():
		push_error("JSON file was empty")
		return {}
	var result:Dictionary = JSON.to_native(JSON.parse_string(text), true)
	if result == null:
		push_error("Invalid JSON format")
		return {}
	return result

#func cast_data(data:Dictionary) -> TileSetData:
	#var out := TileSetData.new()
	#out.name = data["name"]
	#out.res_path = data["resource_path"]
	#out.atlases = data["atlases"]
	#var tile_data:Array[MyTileData]
	#for tile in data["tile_data"]:
		#var my_auto_config := AutoTileConfig.new()
		#my_auto_config.bitmask = tile["autotile"]["bitmask"]
		#my_auto_config.bitmask_mode = tile["autotile"]["bitmask_mode"]
		#my_auto_config.fallback_mode = tile["autotile"]["fallback_mode"]
		#var occluder := LightOccluder.new()
		#if tile["autotile"]["light_occluder"] != null:
			#occluder.closed = tile["autotile"]["light_occluder"]["closed"]
			#occluder.mode = tile["autotile"]["light_occluder"]["mode"]
			#occluder.pool = _string_to_v2_arr(tile["autotile"]["light_occluder"]["pool"])
		#my_auto_config.light_occluder = occluder
		#var nav_polys:Array[PackedVector2Array]
		#if tile["autotile"]["nav_polygon"] != null:
			#for poly in tile["autotile"]["nav_polygon"]:
				#nav_polys.append(_string_to_v2_arr(poly))
		#my_auto_config.nav_polys = nav_polys
		#my_auto_config.size.x = tile["autotile"]["size"][0]
		#my_auto_config.size.y = tile["autotile"]["size"][1]
		#my_auto_config.spacing = tile["autotile"]["spacing"]
		#my_auto_config.subtile_priority = tile["autotile"]["subtile_priority"]
		#my_auto_config.z_index = tile["autotile"]["z_index"]
		#
		#var my_tile := Tile.new()
		#occluder = LightOccluder.new()
		#if tile["tile"]["light_occluder"] != null:
			#occluder.closed = tile["tile"]["light_occluder"]["closed"]
			#occluder.mode = tile["tile"]["light_occluder"]["mode"]
			#occluder.pool = _string_to_v2_arr(tile["tile"]["light_occluder"]["pool"])
		#my_tile.light_occluder = occluder
		#my_tile.material_path = tile["tile"]["material"]
		#my_tile.modulate = _arr_to_color(tile["tile"]["modulate"])
		#my_tile.name = tile["tile"]["name"]
		#my_tile.nav_poly = tile["tile"]["nav_polygon"]
		#my_tile.nav_poly_offs = tile["tile"]["nav_polygon_offs"]
		#my_tile.normal_map_path = tile["tile"]["normal_map"]
		#my_tile.occluder_offs.x = tile["tile"]["occluder_offs"][0]
		#my_tile.occluder_offs.y = tile["tile"]["occluder_offs"][1]
		#my_tile.region = _arr_to_rect2i(tile["tile"]["region"])
		#for shape in tile["tile"]["shapes"]:
			#var my_shape := Shape.new()
			#my_shape.autotile_coord = shape["autotile_coord"]
			#my_shape.one_way = shape["one_way"]
			#my_shape.one_way_margin = shape["one_way_margin"]
			#my_shape.shape[shape["shape"].keys()[0]] = _string_to_v2_arr(shape["shape"].values()[0])
			#my_tile.shapes.append(my_shape)
		#my_tile.texture_path = tile["tile"]["texture"]
		#my_tile.texture_offs.x = tile["tile"]["texture_offs"][0]
		#my_tile.texture_offs.y = tile["tile"]["texture_offs"][1]
		#my_tile.tile_mode = tile["tile"]["tile_mode"]
		#
		#var my_tile_data := MyTileData.new()
		#my_tile_data.id = tile["id"]
		#my_tile_data.coord.x = tile["coord"]["x"]
		#my_tile_data.coord.y = tile["coord"]["y"]
		#my_tile_data.autotile_config = my_auto_config
		#my_tile_data.tile = my_tile
		#out.tile_data.append(my_tile_data)
	#return out

#func create_tileset_from_cast(data:MyTileSetData) -> TileSet:
	#var out := TileSet.new()
	#var sources:Dictionary[String,TileSetAtlasSource]
	#out.add_navigation_layer(0)
	#out.add_occlusion_layer(0)
	#out.add_physics_layer(0)
	#
	## create atlas sources
	#for atlas_path in data.atlases:
		#var source := TileSetAtlasSource.new()
		#source.texture = load(atlas_path)
		#sources[atlas_path] = source
		#out.add_source(source)
	#
	#for tile_data in data.tile_data:
		#if tile_data.tile.tile_mode == TileMode.Auto:
			#print()
		##Process Single Tiles
		#elif  tile_data.tile.tile_mode == TileMode.Single:
			#var source := sources[tile_data.tile.texture_path]
			#var coord = tile_data.coord
			#var region = tile_data.tile.region
			#source.texture_region_size = region.size
			#out.tile_size = region.size
			#if coord.x > region.size.x or coord.y > region.size.y:
				#continue
			#var pos = coord/region.size
			#source.create_tile(pos)
			#var tile:TileData = source.get_tile_data(pos, 0)
			##for indx in tile_data.tile.shapes.size()-1:
				##_create_collision_from_shape(tile, tile_data.tile.shapes[indx], indx)
			#for indx in tile_data.tile.nav_poly.size()-1:
				#var nav_poly := NavigationPolygon.new()
				#nav_poly.add_outline(tile_data.tile.nav_poly[indx])
				#tile.set_navigation_polygon(0, nav_poly)
			#if tile_data.tile.light_occluder.pool.size() == 0:
				#var occ := OccluderPolygon2D.new()
				#occ.closed = tile_data.tile.light_occluder.closed
				#occ.cull_mode = tile_data.tile.light_occluder.mode
				#occ.polygon = tile_data.tile.light_occluder.pool
				#tile.add_occluder_polygon(0)
				#var occ_indx = tile.get_occluder_polygons_count(0)-1
				#tile.set_occluder_polygon(0, occ_indx, occ)
			#
		#elif tile_data.tile.tile_mode == TileMode.Atlas:
			#print()
	#
	#return out

func create_tileset_from_data(data:Dictionary) -> TileSet:
	var out := TileSet.new()
	out.add_navigation_layer(0)
	out.add_occlusion_layer(0)
	out.add_physics_layer(0)
	out.tile_size = Vector2i(64,64)
	
	var groups:Dictionary[String, Array] # {"path":["tile_data"]}
	for tile_data in data["tile_data"]:
		var texture_path = tile_data["tile"]["texture"]
		groups.get_or_add(texture_path, []).append(tile_data)
	
	print("groups: ", groups.keys())
	for path in groups.keys():
		var source := TileSetAtlasSource.new()
		out.add_source(source)
		
		print("path: ", path, 
			"\nsources: ", out.get_source_count(), 
			"\nsource: ", source, "\n")
		source.texture = load(path)
		var sep:float = groups[path][0]["autotile"]["spacing"]
		source.separation = Vector2(sep,sep)
		#var tile_mode = groups[path]["tilemode"]
		if groups[path].size() < 2: # if size is 1 then this is an atlas
			source.texture_region_size = source.texture.get_size()
		else: # if there are more than 1 elements this is a group of single tiles
			var size = Vector2(
				groups[path][0]["tile"]["region"][2], 
				groups[path][0]["tile"]["region"][3])
			source.texture_region_size = size
			out.tile_size = size

		for tile in groups[path]:
			var size = source.texture.get_size()
			var coord = Vector2(tile["coord"]["x"], tile["coord"]["y"])
			var region = Vector2(tile["tile"]["region"][2], tile["tile"]["region"][3])
			var pos = Vector2i(coord/region)
			if pos.x > size.x or pos.y > size.y:
				continue
			
			print("attempting to create tile at ", pos, " in ", data["name"])
			print("source texture size: ", size)
			print("source region size: ", source.texture_region_size)
			print("tile coord (px): ", coord)
			print("tile size (px): ", region)
			source.create_tile(pos)
			
			var tile_data:TileData = source.get_tile_data(pos, 0)
			for indx in tile["tile"]["shapes"].size()-1:
				var shape = tile["tile"]["shapes"][indx]
				var packed_string:String
				#_create_collisions(tile_data, shape, indx)
			if tile["tile"]["nav_polygon"] != null:
				for indx in tile["tile"]["nav_polygon"].size()-1:
					var nav_poly := NavigationPolygon.new()
					nav_poly.add_outline(_string_to_v2_arr(tile["tile"]["nav_polygon"][indx]))
					tile_data.set_navigation_polygon(0, nav_poly)
			if tile["tile"]["light_occluder"] != null:
				#print("occluder: ", tile["tile"]["light_occluder"])
				var occ_poly := OccluderPolygon2D.new()
				occ_poly.polygon = _string_to_v2_arr(tile["tile"]["light_occluder"]["pool"])
				occ_poly.cull_mode = tile["tile"]["light_occluder"]["mode"]
				occ_poly.closed = tile["tile"]["light_occluder"]["closed"]
				tile_data.add_occluder_polygon(0)
				var occ_indx = tile_data.get_occluder_polygons_count(0)-1
				tile_data.set_occluder_polygon(0, occ_indx, occ_poly)
	return out

func _arr_to_rect2i(arr:Array[int]) -> Rect2i:
	return Rect2i(arr[0], arr[1], arr[2], arr[3])

func _arr_to_color(arr:Array[float]) -> Color:
	var out:Color
	out.r = arr[0]
	out.g = arr[1]
	out.b = arr[2]
	out.a = arr[3]
	return out

func _string_to_v2_arr(string:String) -> PackedVector2Array:
	var out: PackedVector2Array
	var strip = string.lstrip("[(").rstrip(")]").remove_chars("(").remove_chars(")").remove_chars(" ")
	var split:PackedStringArray = strip.split(",")
	var indx = 0
	while indx < split.size():
		out.append(
			Vector2(split[indx].to_float(), 
			split[indx+1].to_float()))
		indx+=2
	return out

func _create_collision_from_shape(tile_data:TileData, shape:CollisionShape, indx:int):
	tile_data.set_collision_polygon_points(0, indx, shape.shape)
	tile_data.set_collision_polygon_one_way(0, indx, shape.one_way)
	tile_data.set_collision_polygon_one_way_margin(0, indx, shape.one_way_margin)

#func _create_collisions(tile_data:TileData, shape:Dictionary, indx:int, ):
	#var packed_string:String
	#if shape["shape"].keys()[0] == "Convex":
		#packed_string = shape["shape"]["Convex"]
	#elif shape["shape"].keys()[0] == "Concave":
		#packed_string = shape["shape"]["Concave"]
	#var packed_vec = _string_to_v2_arr(packed_string)
	#tile_data.set_collision_polygon_points(0, indx, packed_vec)
	#tile_data.set_collision_polygon_one_way(0, indx, shape["one_way"])
	#tile_data.set_collision_polygon_one_way_margin(0, indx, shape["one_way_margin"])
				
func _create_dir(path:String, dir_name:String) -> String:
	var full_path = path+"/"+dir_name
	var dir := DirAccess.open(path)
	if not dir.dir_exists(full_path):
		dir.make_dir(full_path)
	return full_path+"/"

enum TileMode {
	Single = 0,
	Auto = 1,
	Atlas = 2
}

func _convert_peeringbits(bits:PeeringBits) -> TileSet.CellNeighbor:
	match bits:
		PeeringBits.RightSide:
			return TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE
		PeeringBits.TopSide:
			return TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_SIDE
		PeeringBits.LeftSide:
			return TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE
		PeeringBits.BottomSide:
			return TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_SIDE
		PeeringBits.BottomRightCorner:
			return TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER
		PeeringBits.TopRightCorner:
			return TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_RIGHT_CORNER
		PeeringBits.BottomLeftCorner:
			return TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER
		_:
			return TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_LEFT_CORNER

enum PeeringBits{
	RightSide, TopSide, LeftSide, BottomSide,
	BottomRightCorner,TopRightCorner,
	BottomLeftCorner,TopLeftCorner,
	Center
}

# yes this is a night mare, it was late. dont judge me
func _decode_bitmask(mask:int) -> Array[PeeringBits]:
	var out:Array[PeeringBits]
	var tracker = mask
	if tracker >= 256:
		tracker -= 256
		out.append(PeeringBits.BottomRightCorner)
	if tracker >= 128:
		tracker -= 128
		out.append(PeeringBits.BottomSide)
	if tracker >= 64:
		tracker -= 64
		out.append(PeeringBits.BottomLeftCorner)
	if tracker >= 32:
		tracker -= 32
		out.append(PeeringBits.RightSide)
	if tracker >= 16:
		tracker -= 16
		out.append(PeeringBits.Center)
	if tracker >= 8:
		tracker -= 8
		out.append(PeeringBits.LeftSide)
	if tracker >= 4:
		tracker -= 4
		out.append(PeeringBits.TopRightCorner)
	if tracker >= 2:
		tracker -= 2
		out.append(PeeringBits.TopSide)
	if tracker >= 1:
		tracker -= 1
		out.append(PeeringBits.TopLeftCorner)
	return out
	
