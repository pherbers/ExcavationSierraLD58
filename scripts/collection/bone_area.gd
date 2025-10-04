extends Area2D

var isAktive: bool = false

func _on_mouse_entered() -> void:
	isAktive = true


func _on_mouse_exited() -> void:
	isAktive = false
