extends Node2D

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

var indicatorQueue: Array[Message] = []
var timer: float = 0;

@onready var shop: Shop = $/root/MainScene/Shop as Shop

@export var toolbelt: Toolbelt

@export var valueOfUndamgedBone = 10
@export var valueOfDamgedBone = 2

@export var isCollectionComplete = false

@onready var feedbackPrefab:PackedScene = preload("res://nodes/indicator.tscn")

class Message:
    var text: String
    var pos: Vector2

func _process(delta: float) -> void:
    if timer > 0:
            timer -= delta
            
    if indicatorQueue.size() > 0:
        if timer <= 0:
            var text = indicatorQueue.pop_front()
            spawn_feedback_text(text)
            timer = 1.4
            

func collect_bone(bone_name: String, numberOfUnBoneDamagedTiles: int, numberOfDamagedBoneTiles:int):
    print("Bone collected: " + bone_name)
    shop.update_coins(numberOfUnBoneDamagedTiles * valueOfUndamgedBone + numberOfDamagedBoneTiles * valueOfDamgedBone)
    if numberOfDamagedBoneTiles <= 0:
        queue_feedback_text("PRISTINE!")
    bone_collected.emit(bone_name)

func get_damages_for_bone(bone_name: String) -> Array[BoneDamage]:
    return BoneCollectionState.get_damages_for_bone(bone_name)

func jump_to_end():
    _FADE.time_to_fade = 5
    _FADE.FadeTo("res://ending_sceme.tscn")  

func setCollectionCompleted():
    if !isCollectionComplete:
        print("Collection is completed!")
        isCollectionComplete = true
        collection_completed.emit()
        jump_to_end()
        
func add_bone_damage(damage: BoneDamage):
    BoneCollectionState.add_bone_damage(damage)

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
 
func queue_feedback_text(value: String):
    var msg = Message.new()
    msg.pos = get_global_mouse_position()
    msg.text = value

    indicatorQueue.append(msg)
   
func spawn_feedback_text(msg: Message):
    var node = feedbackPrefab.instantiate()
    node.lifetime = 5
    node.global_position = msg.pos
    node.z_index = 50
    node.text = msg.text
    add_child(node)

func _on_shop_coins_delter(value: int) -> void:
    if value > 0:
        queue_feedback_text("+$" + str(value))
    else:
        queue_feedback_text("$" + str(value))

func _on_dig_site_hit_bone() -> void:
    queue_feedback_text("Bone DAMAGED!")


func _on_dig_site_bone_stuck() -> void:
    queue_feedback_text("Stuck!")
