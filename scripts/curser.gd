extends Node2D
class_name Curser

@export var curserAnimator: AnimatedSprite2D

@export var toolbelt: Toolbelt
@onready var dig_site: DigSite = $/root/MainScene/DigSite
@export var label:Label

var lastTool: Toolbelt.Tools = Toolbelt.Tools.Hand

func _ready() -> void:
    changeToHand()

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
            
    if currentTool == Toolbelt.Tools.GPR:
        var mouseTile = dig_site.getTileForMousePos()
        var closest_bone_pos = dig_site.get_closest_bone_pos(mouseTile)
        var pos = Vector2i(closest_bone_pos.x, closest_bone_pos.y)
        var depth = closest_bone_pos.z
        var dist = (pos - mouseTile).length()
        if dist < 0.5:
            label.text = "GPR (1) Depth " + str(depth)
        elif dist < 5.:
            label.text = "GPR (2)"
        elif dist < 20.:
            label.text = "GPR (3)"

func changeToShovel():
    curserAnimator.stop()
    curserAnimator.play("Shovel")
    label.text = "Shovel"
    
func changeToTrowel():
    curserAnimator.stop()
    curserAnimator.play("Shovel")
    label.text = "Trowel"
    
func changeToBrush():
    curserAnimator.stop()
    curserAnimator.play("Shovel")
    label.text = "Brush"
    
func changeToHand():
    curserAnimator.stop()
    curserAnimator.play("Shovel")
    label.text = "Hand"
    
func changeToGPR():
    curserAnimator.stop()
    curserAnimator.play("GPR")
    label.text = "GPR"
