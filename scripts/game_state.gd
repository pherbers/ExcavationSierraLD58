extends Node

class_name GameState

signal bone_collected(bone_name: String)
signal collection_completed()

var item_has_shovel = false
var item_has_trowel = false
var item_shovel_big = false
var item_trowel_safe = false
var item_has_gpr = false
var item_gpr_width = 2  # 0, 1, 2
var item_gpr_depth = 2  # max 6

@onready var shop: Shop = $/root/MainScene/Shop as Shop

@export var toolbelt: Toolbelt

@export var valueOfUndamgedBone = 10
@export var valueOfDamgedBone = 2

var bone_damages: Array[BoneDamage]

class BoneDamage:
    var atlas_id: int
    var atlas_pos: Vector2i
    var bone_name: String
    var damage_type: int
    
    func equals(d: BoneDamage) -> bool:
        return d.atlas_id == atlas_id and d.atlas_pos == atlas_pos and d.bone_name == bone_name


@export var isCollectionComplete = false

func collect_bone(bone_name: String, numberOfUnBoneDamagedTiles: int, numberOfDamagedBoneTiles:int):
    print("Bone collected: " + bone_name)
    shop.update_coins(numberOfUnBoneDamagedTiles * valueOfUndamgedBone + numberOfDamagedBoneTiles * valueOfDamgedBone)
    bone_collected.emit(bone_name)

func get_damages_for_bone(bone_name: String) -> Array[BoneDamage]:
    return bone_damages.filter(func(d): return d.bone_name == bone_name)

func setCollectionCompleted():
    if !isCollectionComplete:
        print("Collection is completed!")
        isCollectionComplete = true
        collection_completed.emit()
        get_tree().change_scene_to_file("res://ending_sceme.tscn")
        
func add_bone_damage(damage: BoneDamage):
    bone_damages.append(damage)

func update_tool_state(shopItems: Dictionary[String, Shop.ShopItem]):
    if Toolbelt.currentTool != Toolbelt.Tools.Hand:
        toolbelt.change_tool(Toolbelt.Tools.Hand)
    var shopItemShovel = shopItems["shovel"] as Shop.ShopItem
    if shopItemShovel.currentLevel == 0:
        item_has_shovel = false
        item_shovel_big = false
    elif shopItemShovel.currentLevel == 1:
        item_has_shovel = true
        item_shovel_big = false
    elif shopItemShovel.currentLevel == 2:
        item_has_shovel = true
        item_shovel_big = true
    
    var shopItemTrowel = shopItems["trowel"] as Shop.ShopItem
    if shopItemTrowel.currentLevel == 0:
        item_has_trowel = false
        item_trowel_safe = false
    elif shopItemTrowel.currentLevel == 1:
        item_has_trowel = true
        item_trowel_safe = false
    elif shopItemTrowel.currentLevel == 2:
        item_has_trowel = true
        item_trowel_safe = true
    
    var shopItemGpr = shopItems["gpr"] as Shop.ShopItem
    if shopItemGpr.currentLevel == 0:
        item_has_gpr = false
    if shopItemGpr.currentLevel == 1:
        item_has_gpr = true
        
    var shopItemGprW = shopItems["gpr_width"] as Shop.ShopItem
    item_gpr_width = shopItemGprW.currentLevel
        
    var shopItemGprD = shopItems["gpr_depth"] as Shop.ShopItem
    item_gpr_depth = 3 + shopItemGprD.currentLevel
    
    
func is_tool_available(tool: Toolbelt.Tools) -> bool:
    if tool == Toolbelt.Tools.Hand:
        return true
    if tool == Toolbelt.Tools.Brush:
        return true
    if tool == Toolbelt.Tools.Trowel:
        return item_has_trowel
    if tool == Toolbelt.Tools.Shovel:
        return item_has_shovel
    if tool == Toolbelt.Tools.GPR:
        return item_has_gpr
    return false
    
