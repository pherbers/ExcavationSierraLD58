extends Node
class_name Toolbelt

signal tool_has_changed(newTool:Tools)

@export var digSite: DigSite

var direction: int = 0;

enum Tools {
	Hand,
	Shovel,
	Trowel,
	Brush
}

var tool_dic_mod = {
	Tools.Hand : 8,
	Tools.Shovel : 4,
	Tools.Trowel : 8,
	Tools.Brush : 8
}

static var currentTool: Tools = Tools.Hand

func change_tool(newTool:Tools):
	if currentTool == newTool: return
	currentTool = newTool
	direction = 0
	print(Tools.keys()[currentTool], " Tool selected!")
	tool_has_changed.emit(currentTool)

func change_direction_up():
	direction += 1
	direction = direction % tool_dic_mod[currentTool]
	print("New Direction:", direction)
	
func change_direction_down():
	direction -= 1
	if direction < 0: 
		direction = tool_dic_mod[currentTool] - 1
	print("New Direction:", direction)

func digSiteAktion(pressed:bool):
	if !pressed:
		digSite.is_brushing = false
	else:
		match currentTool:
			Tools.Hand:
				digSite.take_object(digSite.getTileForMousePos())
			Tools.Shovel: 
				digSite.dig_shovel(digSite.getTileForMousePos(), direction)
			Tools.Trowel:
				digSite.dig_trowel(digSite.getTileForMousePos(), direction)
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
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			change_direction_up()
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			change_direction_down()
		
