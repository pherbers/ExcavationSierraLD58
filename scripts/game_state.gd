extends Node

class_name GameState

signal bone_collected(bone_name: String)
signal collection_completed()

var item_has_shovel = true
var item_has_trowel = true
var item_shovel_big = true
var item_trowel_safe = true
var item_has_gpr = true
var item_gpr_width = 2  # 0, 1, 2
var item_gpr_depth = 2  # max 6


var bone_damages: Array[BoneDamage]

class BoneDamage:
    var atlas_id: int
    var atlas_pos: Vector2i
    var bone_name: String
    var damage_type: int
    
    func equals(d: BoneDamage) -> bool:
        return d.atlas_id == atlas_id and d.atlas_pos == atlas_pos and d.bone_name == bone_name
       
@export var isCollectionComplete = false

func collect_bone(bone_name: String):
    print("Bone collected: " + bone_name)
    bone_collected.emit(bone_name)

func get_damages_for_bone(bone_name: String) -> Array[BoneDamage]:
    return bone_damages.filter(func(d): return d.bone_name == bone_name)

func setCollectionCompleted():
    if !isCollectionComplete:
        print("Collection is completed!")
        isCollectionComplete = true
        collection_completed.emit()
        
func add_bone_damage(damage: BoneDamage):
    bone_damages.append(damage)
