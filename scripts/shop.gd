extends Node2D
class_name Shop

@onready var labelPurse: Label = $ShopUI/Purse
@onready var gamestate: GameState = $/root/MainScene/GameState

var shopItems: Dictionary[String, ShopItem]
var coins: int
     
signal shop_has_changed(shopItems: Dictionary[String, ShopItem])
signal coins_has_changed(newValue:int)
signal coins_gained()
signal coins_spent()
signal insufficient_money()

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
            

func update_coins(amount: int):
    self.coins += amount
    labelPurse.text = "$" + str(self.coins)
    coins_has_changed.emit(self.coins)
    Global.set_score(self.coins)
    if amount > 0:
        coins_gained.emit()
    elif amount < 0:
        coins_spent.emit()

func add_100_coin():
    self.update_coins(100)
func remove_100_coin():
    self.update_coins(-100)

func buy_item(shopItem: ShopItem):
    print("Try buying Item!")
    var price = shopItem.current_price()
    if shopItem.can_be_bought(coins):
        print("Bought Item!")
        update_coins(-price)
        shopItem.updateOne()
        shop_has_changed.emit(shopItems)
    else:
        print("Cant buy Item!")
        insufficient_money.emit()

func buy_shovel():
    var shopItem = shopItems["shovel"] as ShopItem
    if shopItem:
        self.buy_item(shopItem)
    else:
        print("No ShopItem!")

func buy_trowel():
    var shopItem = shopItems["trowel"] as ShopItem
    if shopItem:
        self.buy_item(shopItem)
    else:
        print("No ShopItem!")

func buy_gpr():
    var shopItem = shopItems["gpr"] as ShopItem
    if shopItem:
        self.buy_item(shopItem)
    else:
        print("No ShopItem!")
        
func buy_gpr_wight():
    var shopItem = shopItems["gpr_width"] as ShopItem
    if shopItem:
        self.buy_item(shopItem)
    else:
        print("No ShopItem!")

func buy_gpr_depth():
    var shopItem = shopItems["gpr_depth"] as ShopItem
    if shopItem:
        self.buy_item(shopItem)
    else:
        print("No ShopItem!")
        
func _ready() -> void:
    coins = 0
    coins_has_changed.emit()
    shopItems = {}
    #Shovel 
    var shopItemShovel: ShopItem = ShopItem.new()
    shopItemShovel.id = 0;
    shopItemShovel.maxLevel = 2
    shopItemShovel.currentLevel = 0
    shopItemShovel.price = [20, 250]
    shopItems["shovel"] = shopItemShovel

    #Trowel 
    var shopItemTrowel: ShopItem = ShopItem.new()
    shopItemTrowel.id = 1;
    shopItemTrowel.maxLevel = 2
    shopItemTrowel.currentLevel = 0
    shopItemTrowel.price = [10, 400]
    shopItems["trowel"] = shopItemTrowel 
     
    #GPR
    var shopItemGPR: ShopItem = ShopItem.new()
    shopItemGPR.id = 2;
    shopItemGPR.maxLevel = 1
    shopItemGPR.currentLevel = 0
    shopItemGPR.price = [50]
    shopItems["gpr"] = shopItemGPR 
    
    #GPR width
    var shopItemGPRWidth: ShopItem = ShopItem.new()
    shopItemGPRWidth.id = 3;
    shopItemGPRWidth.maxLevel = 2
    shopItemGPRWidth.currentLevel = 0
    shopItemGPRWidth.price = [300, 1000]
    shopItems["gpr_width"] = shopItemGPRWidth 
    
    #GPR depth
    var shopItemGPRDepth: ShopItem = ShopItem.new()
    shopItemGPRDepth.id = 4;
    shopItemGPRDepth.maxLevel = 2
    shopItemGPRDepth.currentLevel = 0
    shopItemGPRDepth.price = [200, 750]
    shopItems["gpr_depth"] = shopItemGPRDepth 
    
    shop_has_changed.connect(update_buttons)
    shop_has_changed.emit(shopItems)
    
func update_buttons(_shopItems):
    $ShopUI/Shovel.disabled = _shopItems["shovel"].currentLevel >= 1
    
    $ShopUI/Shovel2.visible = _shopItems["shovel"].currentLevel >= 1
    $ShopUI/Shovel2.disabled = _shopItems["shovel"].currentLevel >= 2
    
    $ShopUI/Trowel.disabled = _shopItems["trowel"].currentLevel >= 1
    
    $ShopUI/Trowel2.visible =  _shopItems["trowel"].currentLevel >= 1
    $ShopUI/Trowel2.disabled = _shopItems["trowel"].currentLevel >= 2
    
    $ShopUI/GPR.disabled = _shopItems["gpr"].currentLevel >= 1
    
    $ShopUI/GPRDepth.visible = _shopItems["gpr"].currentLevel >= 1
    $ShopUI/GPRDepth.disabled = _shopItems["gpr_depth"].currentLevel != 0
    $ShopUI/GPRDepth2.visible = _shopItems["gpr_depth"].currentLevel >= 1
    $ShopUI/GPRDepth2.disabled = _shopItems["gpr_depth"].currentLevel != 1
    
    $ShopUI/GPRWidth.visible = _shopItems["gpr"].currentLevel >= 1
    $ShopUI/GPRWidth.disabled = _shopItems["gpr_width"].currentLevel != 0
    $ShopUI/GPRWidth2.visible = _shopItems["gpr_width"].currentLevel >= 1
    $ShopUI/GPRWidth2.disabled = _shopItems["gpr_width"].currentLevel != 1
