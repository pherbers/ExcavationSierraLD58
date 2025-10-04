extends Node2D
class_name Curser

func _process(_delta: float):
	var posMouse = get_global_mouse_position()
	print(posMouse)
