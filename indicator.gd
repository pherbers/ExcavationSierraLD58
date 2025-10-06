extends Label
class_name Indicator

var lifetime: float

func _process(delta: float) -> void:
    lifetime -= delta
    var newPos = self.global_position + Vector2.UP * 500
    self.global_position = self.global_position.move_toward(newPos, 15*delta)
    if lifetime < 0:
        queue_free() 
