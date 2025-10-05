extends Node2D
class_name Toolbelt

signal tool_has_changed(newTool:Tools)
signal direction_has_changed(newDir:int)

@export var digSite: DigSite

@onready var camera = $/root/MainScene/Camera2D as Camera2D
@onready var gameState = $/root/MainScene/GameState as GameState

var direction: int = 0;

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

func _ready() -> void:
    get_viewport().size_changed.connect(window_update)
    window_update()

func window_update():
    var zoom = max(floor(get_viewport().get_visible_rect().size.y / 200), 1.)
    print("Setting zoom to " + str(zoom))
    camera.zoom = Vector2i(zoom, zoom)

func change_tool(newTool:Tools):
    if currentTool == newTool: return
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
                digSite.dig_shovel(digSite.getTileForMousePos(), direction)
            Tools.Trowel:
                digSite.dig_trowel(digSite.getTileForMousePos(), direction)
            Tools.Brush:
                digSite.is_brushing = true
            Tools.GPR:
                digSite.place_flag(digSite.getTileForMousePos())

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
