extends Sprite2D
class_name CollectionBone

@export var collection:Collection
@export var button:Button

func _on_button_pressed() -> void:
	collection.changeAktiveBone(self)
