extends Node2D
class_name Toolbelt

signal tool_has_changed(newTool:Tools)
signal direction_has_changed(newDir:int)

@export var digSite: DigSite
@export var collectionSpawnPoint: Node2D

@onready var camera = $/root/MainScene/Camera2D as Camera2D
@onready var gameState = $/root/MainScene/GameState as GameState

@export var toolSprite: Sprite2D
@export var defaultTexture: Texture2D

@export var shovelHighlightedTexture: Texture2D
@export var shovelUsedTexture: Texture2D

@export var trowelHighlightedTexture: Texture2D
@export var trowelUsedTexture: Texture2D

@export var brushHighlightedTexture: Texture2D
@export var brushUsedTexture: Texture2D

@export var gprHighlightedTexture: Texture2D
@export var gprUsedTexture: Texture2D

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
    Tools.Trowel : 8,
    Tools.Brush : 8,
    Tools.GPR : 1
}

static var currentTool: Tools = Tools.Hand

var isInCollection: bool = false
var playerPosOnField: Vector2
var playerPosOnCollection: Vector2

func _ready() -> void:
    playerPosOnField = camera.global_position
    playerPosOnCollection = collectionSpawnPoint.global_position
    
    get_viewport().size_changed.connect(window_update)
    window_update()

func window_update():
    var zoom = max(floor(get_viewport().get_visible_rect().size.y / 200), 1.)
    print("Setting zoom to " + str(zoom))
    camera.zoom = Vector2i(zoom, zoom)

func change_tool(newTool:Tools):
    if currentTool == newTool:
        if currentTool == Tools.Hand:
            return
        else:
            change_tool(Tools.Hand)
            return
    currentTool = newTool
    direction = 0
    tool_has_changed.emit(currentTool)

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
    direction += 1
    direction = direction % tool_dic_mod[currentTool]
    direction_has_changed.emit(direction)
    
func change_direction_down():
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
                    gameState.collect_bone(boneName)
            Tools.Shovel: 
                var result = digSite.dig_shovel(digSite.getTileForMousePos(), direction)
                if result == DigSite.DigResult.OK:
                    shovel_used.emit()
            Tools.Trowel:
                var result = digSite.dig_trowel(digSite.getTileForMousePos(), direction)
                if result == DigSite.DigResult.OK:
                    trowel_used.emit()
            Tools.Brush:
                digSite.is_brushing = true
                brush_used.emit()
            Tools.GPR:
                var result = digSite.place_flag(digSite.getTileForMousePos())
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
    
    if isInCollection:
        playerPosOnCollection = camera.global_position
    else: 
        playerPosOnField = camera.global_position
    
    if currentTool == Tools.Hand:
        if highlightTool == Tools.Hand:
            toolSprite.texture = defaultTexture
        elif highlightTool == Tools.Shovel:
            toolSprite.texture = shovelHighlightedTexture
        elif highlightTool == Tools.Trowel:
            toolSprite.texture = trowelHighlightedTexture
        elif highlightTool == Tools.Brush:
            toolSprite.texture = brushHighlightedTexture
        elif highlightTool == Tools.GPR:
            toolSprite.texture = gprHighlightedTexture
    elif currentTool == Tools.Shovel:
        toolSprite.texture = shovelUsedTexture
    elif currentTool == Tools.Trowel:
        toolSprite.texture = trowelUsedTexture
    elif currentTool == Tools.Brush:
        toolSprite.texture = brushUsedTexture
    elif currentTool == Tools.GPR:
        toolSprite.texture = gprUsedTexture
    
    
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
    if isInCollection:
        camera.global_position = playerPosOnField
        isInCollection = false
    else: 
        camera.global_position = playerPosOnCollection
        isInCollection = true
        
func forcePlayerToCollectionSpawnPoint():
    if isInCollection:
       toggle_collection()
    playerPosOnCollection = collectionSpawnPoint.global_position
    toggle_collection()
