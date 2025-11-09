# Godot TileMap and TileSet conversion for 3x -> 4x
this project contains a set of scripts which are tools for fixing the conversion of TileMaps and TileSets from 3x to 4x. The process is not entirely automatic, a step by step instruction of how to use these tools is described below

### Whats Inside?
```
3x Nodes
	- TileMapExporter.gd  # this class allows exporting of tile map data in your scene
	- TileSetExporter.gd  # this class exports all tilesets in your project dir

4x Addons
	- tilemap_converter  # this addon converts TileMaps 
	- tileset_converter  # this addon converts TileSets
```

**Step 1 - Setup:** copy the 3x Nodes scripts into the Godot-3.x version of your project, and the 4x Addons into the res://addons folder of the converted Godot-4x version of your project. Create a new folder in the root of your 4.x project named "conversion_dump" ( res://conversion_dump )

**Step 2 - Exporting TileSets:** 
1. In any scene that you can play, add a TileSetExporter node to the scene.
2. Input the absolute path of where you want the TileSet data to be exported into the text field in the nodes Inspector.
3. Play that scene.
4. Once you have confirmed the export has occurred, the TileSetExporter node can be deleted from the scene 
This will scan your project directory for .tres files that are of the TileSet type and export a number of JSON files to the specified outside directory. The JSON files will be named the same name as the TileSet resource. This process only needs to be done once

**Step 3 - Exporting TileMaps:**
1. In a scene that contains a TileMap, add a TileMapExporter node to that scene.
2. Input the absolute path of where you want the TileMap data to be exported into the text field in the nodes Inspector.
3. Play that scene
4. Once you have confirmed the export has occurred, the TileMapExporter node can be deleted from the scene
This will scan the tree the TileMapExporter node is placed in for nodes of type TileMap, and export their data to JSON files to the specified outside directory. The JSON files will be named with the same name at the TileMap node they copied. this process must be done for every scene that contains a tile map. 
***Warning:** Nodes that have the same name, will override exported JSON files if they are exported to the same directory.* 

**Step 4 - Importing TileSets:**
1. Right click on a TileSet resource in the FileSystem. At the bottom of the right click menu you will see an option "Convert TileSet". Select it.
2. A file dialogue will open. Navigate to the folder where you exported your TileSet data from 3x and select the JSON file whose name matches the TileSet resource you right clicked.
This will create a new TileSet resource in place of the old one with its data replaced to support the new 4.x TileSet system. The old TileSet is moved into the conversion_dump folder. 

**Step 5 - Importing TileMaps:**
1. Right click on a TileMap resource in the FileSystem. At the bottom of the right click menu you will see an option "Convert TileMap". Select it.
2. A file dialogue will open. Navigate to the folder where you exported your TileMap data from 3x and select the JSON file whose name matches the TileMap node you right clicked.
This will create a new TileMapLayer node in place of the old one and remove the old TileMap from the tree. 