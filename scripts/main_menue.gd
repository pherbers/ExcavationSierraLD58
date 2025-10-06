extends Node2D

@onready var camera = $/root/MainMenue/Camera2D as Camera2D

func _ready() -> void:
    get_viewport().size_changed.connect(window_update)
    window_update()

func play_game():
    _FADE.time_to_fade = 1.5
    _FADE.FadeTo("res://main_scene.tscn")
    $Button.disabled = true

func window_update():
    var zoom = max(floor(get_viewport().get_visible_rect().size.y / 250), 1.)
    print("Setting zoom to " + str(zoom))
    camera.zoom = Vector2i(zoom, zoom)
    
