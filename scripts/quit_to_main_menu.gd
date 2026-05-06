extends CanvasLayer
class_name PauseMenu

@export var paused = false
@export var main_menu_scene  = "res://nodes/main_menue.tscn"

signal on_pause
signal on_unpause

func _ready():
    visible = false

func _input(event: InputEvent):
    if event is InputEventKey and event.is_pressed():
        if event.keycode == Key.KEY_ESCAPE:
            if paused:
                unpause()
            else:
                pause()
        if paused and (event.keycode == Key.KEY_KP_ENTER or event.keycode == Key.KEY_ENTER):
            to_main_menu()

func to_main_menu():
    print("Quitting to main menu")
    unpause()
    var err = get_tree().change_scene_to_file(main_menu_scene)
    if err != OK:
        print("Could not load main menu scene")

func pause():
    paused = true
    get_tree().paused = true
    visible = true
    on_pause.emit()

func unpause():
    paused = false
    get_tree().paused = false
    visible = false
    on_unpause.emit()
