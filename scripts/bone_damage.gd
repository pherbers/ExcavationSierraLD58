class_name BoneDamage

var atlas_id: int
var atlas_pos: Vector2i
var bone_name: String
var damage_type: int
    
func equals(d: BoneDamage) -> bool:
    return d.atlas_id == atlas_id and d.atlas_pos == atlas_pos and d.bone_name == bone_name
