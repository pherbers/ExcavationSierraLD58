extends Button

@export var tollbelt: Toolbelt

func _on_pressed() -> void:
    tollbelt.change_direction_up()
