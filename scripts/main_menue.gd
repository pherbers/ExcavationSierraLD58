extends Node2D

@onready var camera = $/root/MainMenue/Camera2D as Camera2D

func _ready() -> void:
    get_viewport().size_changed.connect(window_update)
    $RandomSeed.text = str(randi())
    window_update()

func play_game():
    ($"/root/Global" as ESGlobal).play_mode = ESGlobal.PlayMode.DEFAULT
    _FADE.time_to_fade = 1.5
    _FADE.FadeTo("res://nodes/main_scene.tscn")
    $Button.disabled = true
    $RandomMode.disabled = true

func play_random_game():
    ($"/root/Global" as ESGlobal).play_mode = ESGlobal.PlayMode.RANDOM
    ($"/root/Global" as ESGlobal).random_seed = abs(hash($RandomSeed.text))
    _FADE.time_to_fade = 1.5
    _FADE.FadeTo("res://nodes/main_scene.tscn")
    $Button.disabled = true
    $RandomMode.disabled = true

func window_update():
    var zoom = max(floor(get_viewport().get_visible_rect().size.y / 250), 1.)
    print("Setting zoom to " + str(zoom))
    camera.zoom = Vector2i(zoom, zoom)
