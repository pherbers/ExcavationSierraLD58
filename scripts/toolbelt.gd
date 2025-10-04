extends Node
class_name Toolbelt

signal tool_has_changed(newTool:Tools)

enum Tools {
	Shovel,
	Trowel,
	Brush
}

static var currentTool: Tools = Tools.Trowel

func change_tool(newTool:Tools):
	if currentTool == newTool: return
	currentTool = newTool
	print(Tools.keys()[currentTool], " Tool selected!")
	tool_has_changed.emit(currentTool)
