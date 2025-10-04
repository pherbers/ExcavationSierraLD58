extends Node2D
class_name Curser

@export var curserAnimator: AnimatedSprite2D

@export var toolbelt: Toolbelt

var lastTool: Toolbelt.Tools = Toolbelt.Tools.Shovel

func _ready() -> void:
	changeToShovel()

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

func changeToShovel():
	curserAnimator.stop()
	curserAnimator.play("Shovel")
	
func changeToTrowel():
	curserAnimator.stop()
	curserAnimator.play("Shovel")
	
func changeToBrush():
	curserAnimator.stop()
	curserAnimator.play("Shovel")
