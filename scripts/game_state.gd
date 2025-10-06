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

signal coins_has_changed(newValue:int)
signal shop_has_changed(shopItems: Array[ShopItem])

@export var toolbelt: Toolbelt


var bone_damages: Array[BoneDamage]

class BoneDamage:
    var atlas_id: int
    var atlas_pos: Vector2i
    var bone_name: String
    var damage_type: int
    
    func equals(d: BoneDamage) -> bool:
        return d.atlas_id == atlas_id and d.atlas_pos == atlas_pos and d.bone_name == bone_name

var shopItems: Array[ShopItem]
     
class ShopItem:
    var id: int
    var maxLevel: int
    var currentLevel: int 
    var price: Array[int]
    
    func isMaxLevel():
        if self.currentLevel < self.maxLevel:
            return false
        return true
    
    func current_price():
        if self.currentLevel < price.size(): 
            return price[self.currentLevel]
        else:
            return -1
    
    func updateOne():
        if !self.isMaxLevel():
            self.currentLevel += 1
            return true
        else:
            return false
            
    func self_print():
        print(
            "Name: ", self.tool, " ", self.id,
            " Level: ", self.currentLevel, "/", self.maxLevel,
            " Prices: ", self.price,
            )
            
    func can_be_bought(coins:int):
        var currentPrice = self.current_price()
        if !self.isMaxLevel() and currentPrice != -1 and currentPrice <= coins:
            return true
        return false
            
            
var coins: int

@export var isCollectionComplete = false

func _ready() -> void:
    coins = 0
    coins_has_changed.emit()
    
    shopItems = []
    #Shovel 
    var shopItemShovel: ShopItem = ShopItem.new()
    shopItemShovel.id = 0;
    shopItemShovel.maxLevel = 2
    shopItemShovel.currentLevel = 0
    shopItemShovel.price = [20, 150]
    shopItems.append(shopItemShovel)

    #Trowel 
    var shopItemTrowel: ShopItem = ShopItem.new()
    shopItemTrowel.id = 1;
    shopItemTrowel.maxLevel = 2
    shopItemTrowel.currentLevel = 0
    shopItemTrowel.price = [25, 300]
    shopItems.append(shopItemTrowel) 
     
    #GPR
    var shopItemGPR: ShopItem = ShopItem.new()
    shopItemGPR.id = 2;
    shopItemGPR.maxLevel = 1
    shopItemGPR.currentLevel = 0
    shopItemGPR.price = [50]
    shopItems.append(shopItemGPR) 
    
    #GPR width
    var shopItemGPRWidth: ShopItem = ShopItem.new()
    shopItemGPRWidth.id = 3;
    shopItemGPRWidth.maxLevel = 3
    shopItemGPRWidth.currentLevel = 0
    shopItemGPRWidth.price = [125, 250, 500]
    shopItems.append(shopItemGPRWidth) 
    
    #GPR depth
    var shopItemGPRDepth: ShopItem = ShopItem.new()
    shopItemGPRDepth.id = 4;
    shopItemGPRDepth.maxLevel = 3
    shopItemGPRDepth.currentLevel = 0
    shopItemGPRDepth.price = [125, 250, 500]
    shopItems.append(shopItemGPRDepth) 
    
    shop_has_changed.emit(shopItems)

func collect_bone(bone_name: String, numberOfBoneTiles: int):
    print("Bone collected: " + bone_name)
    update_coins(numberOfBoneTiles * 5)
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

func update_coins(amount: int):
    self.coins += amount
    coins_has_changed.emit(self.coins)

func add_100_coin():
    self.update_coins(100)
func remove_100_coin():
    self.update_coins(-100)

func buy_item(shopItem: ShopItem):
    if Toolbelt.currentTool != Toolbelt.Tools.Hand:
        toolbelt.change_tool(Toolbelt.Tools.Hand)
    print("Try buying Item!")
    var price = shopItem.current_price()
    if shopItem.can_be_bought(coins):
        print("Bought Shovel!")
        update_coins(-price)
        shopItem.updateOne()
        update_tool_state()
        shop_has_changed.emit(shopItems)
    else:
        print("Cant buy Shovel!")

func buy_shovel():
    var shopItem = shopItems[0] as ShopItem
    if shopItem:
        self.buy_item(shopItem)
    else:
        print("No ShopItem!")

func buy_trowel():
    var shopItem = shopItems[1] as ShopItem
    if shopItem:
        self.buy_item(shopItem)
    else:
        print("No ShopItem!")

func buy_gpr():
    var shopItem = shopItems[2] as ShopItem
    if shopItem:
        self.buy_item(shopItem)
    else:
        print("No ShopItem!")
        
func buy_gpr_wight():
    var shopItem = shopItems[3] as ShopItem
    if shopItem:
        self.buy_item(shopItem)
    else:
        print("No ShopItem!")

func buy_gpr_depth():
    var shopItem = shopItems[4] as ShopItem
    if shopItem:
        self.buy_item(shopItem)
    else:
        print("No ShopItem!")
        
func update_tool_state():
    var shopItemShovel = shopItems[0] as ShopItem
    if shopItemShovel.currentLevel == 0:
        item_has_shovel = false
        item_shovel_big = false
    elif shopItemShovel.currentLevel == 1:
        item_has_shovel = true
        item_shovel_big = false
    elif shopItemShovel.currentLevel == 2:
        item_has_shovel = true
        item_shovel_big = true
    
    var shopItemTrowel = shopItems[1] as ShopItem
    if shopItemTrowel.currentLevel == 0:
        item_has_trowel = false
        item_trowel_safe = false
    elif shopItemTrowel.currentLevel == 1:
        item_has_trowel = true
        item_trowel_safe = false
    elif shopItemTrowel.currentLevel == 2:
        item_has_trowel = true
        item_trowel_safe = true
    
    var shopItemGpr = shopItems[2] as ShopItem
    if shopItemGpr.currentLevel == 0:
        item_has_gpr = false
    if shopItemGpr.currentLevel == 1:
        item_has_gpr = true
        
    var shopItemGprW = shopItems[3] as ShopItem
    item_gpr_width = shopItemGprW.currentLevel
        
    var shopItemGprD = shopItems[4] as ShopItem
    item_gpr_depth = 3 + shopItemGprD.currentLevel
    
    
