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
            "found": false,
            "damaged": false
        })
        
        tileMap.set_cell(index, -1)
    
func revalDinoBone(boneName: String):
    if !boneDict.has(boneName):     
        pass
    else:
        var entry = boneDict[boneName]
        var cells = entry['boneCells']
        
        # Get damages
        var gameState = $/root/MainScene/GameState as GameState
        var damages = gameState.get_damages_for_bone(boneName)
        print(str(len(damages)) + " Damages on Bone " + boneName)
        for cell in cells:
            var index: Vector2i = cell["index"]
            var sourcId: int = cell["sourcId"]
            var alternativeTile: int = cell["alternativeTile"]
            var atlasCoords: Vector2i = cell["atlasCoords"]
            var found: bool = cell["found"]
            
            # look up damages
            var dmgIndex = damages.find_custom(func(d): return d.atlas_id == sourcId and d.atlas_pos == atlasCoords)
            if dmgIndex != -1:
                var dmg = damages[dmgIndex]
                create_damage_viz(index, dmg.damage_type)
                cell["damaged"] = true
            
            if !found:
                tileMap.set_cell(index, sourcId, atlasCoords, alternativeTile)
                cell.found = true
                
                
    checkIfCompleted()

func create_damage_viz(pos: Vector2i, damage_type: int):
    var damageviz = Sprite2D.new()
    var damage_sprites = $/root/MainScene/DigSite.damage_sprites
    var tex = damage_sprites[damage_type]
    damageviz.texture = tex
    damageviz.position = tileMap.map_to_local(pos)
    add_child(damageviz)
    
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
   
class Bone:
    var name:String
    var countOfBonesUndamaged: int
    var countOfBonesDamaged: int

func get_bone_at_world_pos(globlePos: Vector2) -> Bone:
    var index: Vector2i = tileMap.local_to_map(tileMap.to_local(globlePos))
    var cell: TileData = tileMap.get_cell_tile_data(index)
    if cell == null:
        return null
    if !cell.has_custom_data("ObjectID"):
        return null
    var cellCustomData = cell.get_custom_data("ObjectID")
    var boneNamer = str(cellCustomData)
    
    if boneDict.keys().has(boneNamer):
        var entry = boneDict[boneNamer]
        var countOfBonesUndamaged: int = 0
        var countOfBonesDamaged: int = 0
        var boneCells = entry["boneCells"]
        for boneCell in boneCells:
            if boneCell["damaged"] == true:
                countOfBonesDamaged += 1
            else:
                countOfBonesUndamaged += 1
        
        var bone = Bone.new()
        bone.name = boneNamer
        bone.countOfBonesDamaged = countOfBonesDamaged
        bone.countOfBonesUndamaged = countOfBonesUndamaged
        
        return bone
    
    return null
    
func setComplete():
    label.text = dinoName
    label.visible = true
    on_area_complete.emit()
    
func revalAll():
    for keys in boneDict.keys():
        revalDinoBone(keys)
            
func _on_collection_bone_collected(bone_name: String) -> void:
    revalDinoBone(bone_name)
