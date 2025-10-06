extends Node2D

@export var labelScore: Label

@onready var camera = $/root/EndingSceme/Camera2D as Camera2D

func _ready() -> void:
    get_viewport().size_changed.connect(window_update)
    window_update()
    labelScore.text = "$" + str(Global.get_score()) + "00"

func play_game():
    get_tree().change_scene_to_file("res://main_menue.tscn")

func window_update():
    var zoom = max(floor(get_viewport().get_visible_rect().size.y / 250), 1.)
    print("Setting zoom to " + str(zoom))
    camera.zoom = Vector2i(zoom, zoom)
