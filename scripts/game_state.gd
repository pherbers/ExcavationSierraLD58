extends Node

class_name GameState

signal bone_collected(bone_name: String)
signal collection_completed()

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
    
func buy_shovel():
    print("Buy Shovel")

func buy_trowel():
    print("Buy Trowel")
    
func buy_brush():
    print("Buy Brush")

func buy_gpr():
    print("Buy GPR")
