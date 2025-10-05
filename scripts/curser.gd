extends Node2D
class_name Curser

@export var curserAnimator: AnimatedSprite2D

@export var toolbelt: Toolbelt
@onready var dig_site: DigSite = $/root/MainScene/DigSite
@export var label:Label

var lastTool: Toolbelt.Tools = Toolbelt.Tools.Hand

func _ready() -> void:
    changeToHand()

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
            curserAnimator.play()
        elif !event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
            curserAnimator.stop()

func _process(_delta: float):
    var posMouse = get_global_mouse_position()
    position = posMouse
    
    var currentTool = toolbelt.currentTool;
    if currentTool != lastTool:
        lastTool = currentTool
        if currentTool == Toolbelt.Tools.Shovel:
            changeToShovel()
        elif currentTool == Toolbelt.Tools.Trowel:
            changeToTrowel()
        elif currentTool == Toolbelt.Tools.Brush:
            changeToBrush()
        elif currentTool == Toolbelt.Tools.Hand:
            changeToHand()
        elif currentTool == Toolbelt.Tools.GPR:
            changeToGPR()
            
    if currentTool == Toolbelt.Tools.GPR:
        var mouseTile = dig_site.getTileForMousePos()
        var closest_bone_pos = dig_site.get_closest_bone_pos(mouseTile)
        var pos = Vector2i(closest_bone_pos.x, closest_bone_pos.y)
        var depth = closest_bone_pos.z
        var dist = (pos - mouseTile).length()
        if dist < 0.5:
            match depth:
                1: 
                    curserAnimator.frame = 4
                2:
                    curserAnimator.frame = 5
                3:
                    curserAnimator.frame = 6
                4:
                    curserAnimator.frame = 7
                5:
                    curserAnimator.frame = 8
                _:
                    curserAnimator.frame = 8
        elif dist < 5.:
            curserAnimator.frame = 3
        elif dist < 15.:
            curserAnimator.frame = 2
        elif dist < 25.:
            curserAnimator.frame = 1
        elif dist < 30.:
            curserAnimator.frame = 0

func changeToShovel():
    curserAnimator.visible = true
    curserAnimator.play("Shovel")
    curserAnimator.stop()
    curserAnimator.frame = 0
    label.text = "Shovel"
    label.visible = false
    Input.set_default_cursor_shape(Input.CURSOR_ARROW)
    
func changeToTrowel():
    curserAnimator.visible = true
    curserAnimator.play("Trowel")
    curserAnimator.stop()
    curserAnimator.frame = 0
    label.text = "Trowel"
    label.visible = false
    Input.set_default_cursor_shape(Input.CURSOR_ARROW)
    
func changeToBrush():
    curserAnimator.visible = true
    curserAnimator.play("Brush")
    curserAnimator.stop()
    curserAnimator.frame = 0
    label.text = "Brush"
    label.visible = false
    Input.set_default_cursor_shape(Input.CURSOR_ARROW)
    
func changeToHand():
    curserAnimator.visible = false
    curserAnimator.stop()
    curserAnimator.frame = 0
    label.text = "Hand"
    label.visible = false
    Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
    
func changeToGPR():
    curserAnimator.visible = true
    curserAnimator.play("GPR")
    curserAnimator.stop()
    curserAnimator.frame = 0
    label.text = "GPR"
    label.visible = false
    Input.set_default_cursor_shape(Input.CURSOR_ARROW)
