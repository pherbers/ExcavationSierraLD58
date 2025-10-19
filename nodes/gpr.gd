extends Node2D

@onready var dig_site: DigSite = $/root/MainScene/DigSite
@onready var game_state: GameState = $/root/MainScene/GameState

@export var gpr_speed: float = 1./6.

var tiles: Array[Vector3i]
var _t: float = 0

func _ready() -> void:
    var dig_layer = dig_site.dig_layers[0]
    game_state.item_gpr_placed = true
    global_position = dig_layer.to_global(dig_layer.map_to_local(dig_layer.local_to_map(dig_layer.to_local(global_position))))
    tiles = dig_site.get_gpr_tiles(game_state.item_gpr_width).duplicate()
    tiles.sort_custom(func(v1, v2): return v1.z > v2.z)

func _process(delta: float) -> void:
    _t += delta
    while tiles.size() > 0:
        if tiles.back().z / 256. / gpr_speed < _t:
            var pd = tiles.pop_back()
            plant_flag(Vector2i(pd.x, pd.y))
        else:
            break

func plant_flag(pd: Vector2i):
    var dig_layer = dig_site.dig_layers[0]
    var p = dig_layer.local_to_map(dig_layer.to_local(global_position))
    dig_site.place_flag(p + pd)

func _exit_tree() -> void:
    var gs = game_state
    if gs:
        gs.item_gpr_placed = false
    var t = $/root/MainScene/Toolbelt
    if t:
        t.change_tool(Toolbelt.Tools.GPR)

func pick_up():
    var t = $/root/MainScene/Toolbelt as Toolbelt
    if t.currentTool == Toolbelt.Tools.Hand:
        queue_free()
