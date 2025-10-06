extends Node

var bone_damages: Array[BoneDamage]

func _ready() -> void:
    bone_damages = []
    
func add_bone_damage(damage: BoneDamage):
    BoneCollectionState.bone_damages.append(damage)
    
func get_damages_for_bone(bone_name: String) -> Array[BoneDamage]:
    return BoneCollectionState.bone_damages.filter(func(d): return d.bone_name == bone_name)
