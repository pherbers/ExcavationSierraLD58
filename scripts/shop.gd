extends Node2D
class_name Shop

@export var labelPurse: Label

func coins_has_changed(newValue: int) -> void:
    labelPurse.text = "Coins: " + str(newValue)


func _on_game_state_shop_has_changed(shopItems: Array[GameState.ShopItem]) -> void:
    var shopItemShovel = shopItems[0] as GameState.ShopItem
    if shopItemShovel.currentLevel == 0:
        pass
    elif shopItemShovel.currentLevel == 1:
        pass
    elif shopItemShovel.currentLevel == 2:
        pass
        
    var shopItemTrowel = shopItems[1] as GameState.ShopItem
    if shopItemTrowel.currentLevel == 0:
        pass
    elif shopItemTrowel.currentLevel == 1:
        pass
    elif shopItemTrowel.currentLevel == 2:
        pass
    
    var shopItemGpr = shopItems[2] as GameState.ShopItem
    if shopItemGpr.currentLevel == 0:
        pass
    if shopItemGpr.currentLevel == 1:
        pass
        
    var shopItemGprW = shopItems[3] as GameState.ShopItem
    
        
    var shopItemGprD = shopItems[4] as GameState.ShopItem
