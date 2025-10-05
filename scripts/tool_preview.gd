extends Node2D

@onready var dig_site = $/root/MainScene/DigSite as DigSite
@onready var toolbelt = $/root/MainScene/Toolbelt as Toolbelt

@export var tile_sprite: Texture2D

func _ready() -> void:
    toolbelt.tool_has_changed.connect(func(_x): tool_changed())
    toolbelt.direction_has_changed.connect(func(_x): tool_changed())

func tool_changed():
    match toolbelt.currentTool:
        Toolbelt.Tools.Shovel:
            change_visuals(dig_site.get_shovel_tiles(toolbelt.direction))
        Toolbelt.Tools.Trowel:
            change_visuals(dig_site.get_trowel_tiles(toolbelt.direction))
        _:
            change_visuals([])

func change_visuals(cells: Array[Vector3i]):
    for c in get_children():
        c.queue_free()
    for c in cells:
        var s = Sprite2D.new()
        s.texture = tile_sprite
        s.position = Vector2i(c.x, c.y) * 8
        add_child(s)
        

func _input(event) -> void:
    if event is InputEventMouseMotion:
        var layer = dig_site.dig_layers[0] as TileMapLayer
        global_position = layer.to_global(layer.map_to_local(layer.local_to_map(layer.get_local_mouse_position())))
