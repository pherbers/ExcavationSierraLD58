extends Node2D
class_name Curser

@export var curserAnimator: AnimatedSprite2D

@export var toolbelt: Toolbelt
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
