extends Node2D
class_name Collection

@export var toolbelt: Toolbelt

@export var spawnPoint: Node2D
@export var collection: Node
@export var prefab: PackedScene

@export var baseWorkArea: TileMapLayer

var aktiveBones = {}

var selectedBone: CollectionBone = null

func _ready() -> void:
    createBone("bone_d_1_b_5")
        
func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.pressed and event.button_index == MOUSE_BUTTON_LEFT and toolbelt.currentTool == Toolbelt.Tools.Hand:
            performAktion()
    if selectedBone != null and toolbelt.currentTool != Toolbelt.Tools.Hand:
        resetSelectedBone()
        dropBone()

func _process(_delta: float):
    if selectedBone != null:
        var posMouse = get_global_mouse_position()
        selectedBone.global_position = posMouse
    
        var boundingBox = baseWorkArea.get_used_rect();
        var globalStart = baseWorkArea.to_global(baseWorkArea.map_to_local(boundingBox.position))
        var globalSize = baseWorkArea.map_to_local(boundingBox.size)
        var rect: Rect2 = Rect2(globalStart, globalSize)
    
        if !rect.has_point(posMouse):
            resetSelectedBone()
            dropBone()
        
    

func createBone(nameOfBone: String):
    var newBode: CollectionBone = prefab.instantiate()
    newBode.position = spawnPoint.position
    newBode.collection = self
    collection.add_child(newBode)
    
    var loaded: PackedScene = load("res://nodes/bones/" + nameOfBone + ".tscn")
    var nodeTile: TileMapLayer = loaded.instantiate()
    nodeTile.scale = Vector2(5, 5)
    newBode.add_child(nodeTile)
    
    var boundingRectI = nodeTile.get_used_rect()
    var globalStart = nodeTile.to_global(nodeTile.map_to_local(boundingRectI.position))
    var globalEnd = nodeTile.to_global(nodeTile.map_to_local(boundingRectI.end))
    
    var diff = globalEnd - globalStart
    
    newBode.collider.shape.set_size(diff * 6)
    

func resetSelectedBone():
    if selectedBone == null:
        pass
    else:
        selectedBone.position = spawnPoint.position

func performAktion(): 
    if selectedBone == null:
        pickUpBone()
    else:
        dropBone()

func pickUpBone():
    var canndidate = findBestBone()
    if canndidate != null:
        selectedBone = canndidate

func dropBone():
    if selectedBone != null:
        selectedBone = null

func findBestBone(): 
    var canndidate: CollectionBone = null
    for boneId in aktiveBones.keys():
        var bone: CollectionBone = aktiveBones[boneId]
        if canndidate == null:
            canndidate = bone
        else:
            if canndidate.z_index < bone.z_index:
                canndidate = bone
    return canndidate

func add_bone(newBone: CollectionBone):
    aktiveBones[newBone.get_instance_id()] = newBone

func remove_bone(newBone: CollectionBone):
    aktiveBones.erase(newBone.get_instance_id())
