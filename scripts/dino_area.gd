extends Node2D
class_name DinoArea

signal on_area_complete()

@export var tileMap: TileMapLayer
@export var label: Label
@export var dinoName: String

var boneDict = {}
var isCompleted: bool

func _ready() -> void:
    label.visible = false
    isCompleted = false
    
    var cells: Array[Vector2i] = tileMap.get_used_cells()
    for index: Vector2i in cells:
        var cell: TileData = tileMap.get_cell_tile_data(index)
        var cellCustomData = cell.get_custom_data("ObjectID")
        var boneNamer = str(cellCustomData)
        
        if !boneDict.has(boneNamer) :
            boneDict[boneNamer] = {
                "boneCells": [] 
            }
        
        boneDict[boneNamer]["boneCells"].push_back({
            "index": index,
            "sourcId": tileMap.get_cell_source_id(index),
            "alternativeTile": tileMap.get_cell_alternative_tile(index),
            "atlasCoords": tileMap.get_cell_atlas_coords(index),
            "found": false
        })
        
        tileMap.set_cell(index, -1)
    
func revalDinoBone(boneName: String):
    if !boneDict.has(boneName):     
        pass
    else:
        var entry = boneDict[boneName]
        var cells = entry['boneCells']
        for cell in cells:
            var index: Vector2i = cell["index"]
            var sourcId: int = cell["sourcId"]
            var alternativeTile: int = cell["alternativeTile"]
            var atlasCoords: Vector2i = cell["atlasCoords"]
            var found: bool = cell["found"]
            
            if !found:
                tileMap.set_cell(index, sourcId, atlasCoords, alternativeTile)
                cell.found = true
                
    checkIfCompleted()

func checkIfCompleted():
    var isComplete: bool = true;
    for keys in boneDict.keys():
        var entry = boneDict[keys]
        var cells = entry['boneCells']
        for cell in cells:
            var found: bool = cell["found"]
            if !found: 
                isComplete = false
                
    if isComplete:
        setComplete()
            
func setComplete():
    label.text = dinoName
    label.visible = true
    on_area_complete.emit()
    
func revalAll():
    for keys in boneDict.keys():
        revalDinoBone(keys)
            
func _on_collection_bone_collected(bone_name: String) -> void:
    revalDinoBone(bone_name)
