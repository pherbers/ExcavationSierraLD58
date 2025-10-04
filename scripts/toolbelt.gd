extends Node
class_name Toolbelt

signal tool_has_changed(newTool:Tools)

@export var digSite: DigSite

var isAktive: bool = false

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

func digSiteAktion(pressed:bool):
	if !pressed:
		digSite.is_brushing = false
	else:
		match currentTool:
			Tools.Shovel: 
				digSite.dig_shovel(digSite.getTileForMousePos(), 0)
			Tools.Trowel:
				digSite.dig_trowel(digSite.getTileForMousePos(), 0)
			Tools.Brush:
				digSite.is_brushing = true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			change_tool(Tools.Hand)
		elif event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			digSiteAktion(true)
		elif !event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			digSiteAktion(false)
		
