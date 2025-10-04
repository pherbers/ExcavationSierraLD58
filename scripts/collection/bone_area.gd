extends Area2D

var cb: CollectionBone

func _ready() -> void:
	cb = self.get_parent()

func _on_mouse_entered() -> void:
	cb.collection.add_bone(self.get_parent())


func _on_mouse_exited() -> void:
	cb.collection.remove_bone(self.get_parent())
