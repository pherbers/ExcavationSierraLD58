extends Node2D

@export var steps = 3
@export var step_size = 3
@export var step_time = 1.5

var _step_counter = 1
@onready var dig_site: DigSite

func _ready() -> void:
    dig_site = $/root/MainScene/DigSite
    var dig_layer = dig_site.dig_layers[0]
    $/root/MainScene/GameState.item_gpr_placed = true
    global_position = dig_layer.to_global(dig_layer.map_to_local(dig_layer.local_to_map(dig_layer.to_local(global_position))))
    launch_timer()

func launch_timer():
    if _step_counter > steps:
        return
    var timer = Timer.new()
    timer.wait_time = step_time
    timer.one_shot = true
    timer.timeout.connect(plant_flag)
    add_child(timer)
    timer.start()

func plant_flag():
    var dig_layer = dig_site.dig_layers[0]
    for v in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]:
        var p = dig_layer.local_to_map(dig_layer.to_local(global_position))
        dig_site.place_flag(p + (v * _step_counter * steps))
    _step_counter += 1
    launch_timer()

func _exit_tree() -> void:
    var gs = $/root/MainScene/GameState
    if gs:
        gs.item_gpr_placed = false
    var t = $/root/MainScene/Toolbelt
    if t:
        t.change_tool(Toolbelt.Tools.GPR)

func pick_up():
    var t = $/root/MainScene/Toolbelt as Toolbelt
    if t.currentTool == Toolbelt.Tools.Hand:
        queue_free()
