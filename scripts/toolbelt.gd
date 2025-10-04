extends Node
class_name Toolbelt

signal tool_has_changed(newTool:Tools)

enum Tools {
	Hand,
	Shovel,
	Trowel,
	Brush
}

static var currentTool: Tools = Tools.Hand

func change_tool(newTool:Tools):
	if currentTool == newTool: return
	currentTool = newTool
	print(Tools.keys()[currentTool], " Tool selected!")
	tool_has_changed.emit(currentTool)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			change_tool(Tools.Hand)
