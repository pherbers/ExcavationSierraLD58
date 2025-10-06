extends Node2D
class_name Toolbelt

signal tool_has_changed(newTool:Tools)
signal direction_has_changed(newDir:int)

@export var digSite: DigSite
@export var collectionSpawnPoint: Node2D
@export var shopSpawnPoint: Node2D

@onready var camera = $/root/MainScene/Camera2D as Camera2D
@onready var gameState = $/root/MainScene/GameState as GameState

@export var toolSprite: Sprite2D

@export var shovelSprite: Sprite2D
@export var shovelDefaultTexture: Texture2D
@export var shovelHighlightedTexture: Texture2D

@export var trowelSprite: Sprite2D
@export var trowelDefaultTexture: Texture2D
@export var trowelHighlightedTexture: Texture2D

@export var brushSprite: Sprite2D
@export var brushDefaultTexture: Texture2D
@export var brushHighlightedTexture: Texture2D

@export var gprSprite: Sprite2D
@export var gprDefaultTexture: Texture2D
@export var gprHighlightedTexture: Texture2D

var direction: int = 0;
var highlightTool: Tools = Tools.Hand

signal shovel_used
signal trowel_used
signal brush_used
signal gpr_used

enum Tools {
    Hand,
    Shovel,
    Trowel,
    Brush,
    GPR
}

var tool_dic_mod = {
    Tools.Hand : 8,
    Tools.Shovel : 4,
    Tools.Trowel : 4,
    Tools.Brush : 8,
    Tools.GPR : 1
}

static var currentTool: Tools = Tools.Hand

var playerPosOnField: Vector2
var playerPosOnShop: Vector2
var playerPosOnCollection: Vector2

func _ready() -> void:
    playerPosOnField = camera.global_position
    playerPosOnCollection = collectionSpawnPoint.global_position
    playerPosOnShop = shopSpawnPoint.global_position
    
    get_viewport().size_changed.connect(window_update)
    window_update()

func window_update():
    var zoom = max(floor(get_viewport().get_visible_rect().size.y / 250), 1.)
    print("Setting zoom to " + str(zoom))
    camera.zoom = Vector2i(zoom, zoom)

func change_tool(newTool:Tools):
    if currentTool == newTool:
        if currentTool == Tools.Hand:
            return
        else:
            change_tool(Tools.Hand)
            return
    if !gameState.is_tool_available(newTool):
        return
    currentTool = newTool
    direction = 0
    if currentTool == Tools.GPR or currentTool == Tools.Brush:
        direction = 5
    tool_has_changed.emit(currentTool)
    direction_has_changed.emit(direction)

func switch_to_shovel():
    change_tool(Tools.Shovel)
func switch_to_trowel():
    change_tool(Tools.Trowel)
func switch_to_brush():
    change_tool(Tools.Brush)
func switch_to_GPR():
    change_tool(Tools.GPR)
func switch_to_hand():
    change_tool(Tools.Hand)

func change_direction_up():
    if !(currentTool == Tools.Shovel or currentTool == Tools.Trowel):
        return 
    direction += 1
    direction = direction % tool_dic_mod[currentTool]
    direction_has_changed.emit(direction)
    
func change_direction_down():
    if !(currentTool == Tools.Shovel or currentTool == Tools.Trowel):
        return
    direction -= 1
    if direction < 0: 
        direction = tool_dic_mod[currentTool] - 1
    direction_has_changed.emit(direction)

func digSiteAktion(pressed:bool):
    if !pressed:
        digSite.is_brushing = false
    else:
        match currentTool:
            Tools.Hand:
                var boneName = digSite.take_object(digSite.getTileForMousePos())
                if boneName != "":
                    gameState.collect_bone(
                        boneName, 
                        digSite.lastTakenBoneUndamaged,
                        digSite.lastTakenBoneDamaged
                        )
            Tools.Shovel:
                var result = digSite.dig_shovel(digSite.getTileForMousePos(), direction, gameState.item_shovel_big)
                if result == DigSite.DigResult.OK:
                    shovel_used.emit()
            Tools.Trowel:
                var result = digSite.dig_trowel(digSite.getTileForMousePos(), direction, gameState.item_trowel_safe)
                if result == DigSite.DigResult.OK:
                    trowel_used.emit()
            Tools.Brush:
                digSite.is_brushing = true
                brush_used.emit()
            Tools.GPR:
                var result = digSite.place_multi_flag(digSite.getTileForMousePos(), gameState.item_gpr_width)
                if result == DigSite.DigResult.OK:
                    gpr_used.emit()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey:
        if event.pressed and event.keycode == KEY_1:
            change_tool(Tools.Hand)
    if event is InputEventMouseButton:
        if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
            change_tool(Tools.Hand)
        elif event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
            digSiteAktion(true)
        elif !event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
            digSiteAktion(false)
        elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
            change_direction_up()
        elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            change_direction_down()
        

func _process(_delta: float) -> void:
    var camBottomRight = camera.get_screen_center_position() + Vector2(get_viewport_rect().size / camera.zoom / 2)
    global_position = camBottomRight
        
    shovelSprite.texture = shovelDefaultTexture
    trowelSprite.texture = trowelDefaultTexture
    brushSprite.texture = brushDefaultTexture
    gprSprite.texture = gprDefaultTexture
    
    if highlightTool == Tools.Shovel:
        shovelSprite.texture = shovelHighlightedTexture
    if highlightTool == Tools.Trowel:
        trowelSprite.texture = trowelHighlightedTexture
    if highlightTool == Tools.Brush:
        brushSprite.texture = brushHighlightedTexture
    if highlightTool == Tools.GPR:
        gprSprite.texture = gprHighlightedTexture
        
    shovelSprite.visible = true
    trowelSprite.visible = true
    brushSprite.visible = true
    gprSprite.visible = true
    if currentTool == Tools.Shovel or !gameState.is_tool_available(Tools.Shovel):
        shovelSprite.visible = false
    if currentTool == Tools.Trowel or !gameState.is_tool_available(Tools.Trowel):
        trowelSprite.visible = false
    if currentTool == Tools.Brush or !gameState.is_tool_available(Tools.Brush):
        brushSprite.visible = false
    if currentTool == Tools.GPR or !gameState.is_tool_available(Tools.GPR):
        gprSprite.visible = false
        
func reset_highlight():
    highlightTool = Tools.Hand    
    
func highlight_shove():
    highlightTool = Tools.Shovel
    
func highlight_brush():
    highlightTool = Tools.Brush
    
func highlight_trowel():
    highlightTool = Tools.Trowel
    
func highlight_gpr():
    highlightTool = Tools.GPR
    
func toggle_collection():
    if (playerPosOnShop - camera.global_position).length() < 200:
        camera.global_position = playerPosOnCollection
    elif (playerPosOnCollection - camera.global_position).length() < 200:
        camera.global_position = playerPosOnField
    else:
        playerPosOnField = camera.global_position
        camera.global_position = playerPosOnShop

        
func forcePlayerToCollectionSpawnPoint():
    playerPosOnCollection = collectionSpawnPoint.global_position
    toggle_collection()
