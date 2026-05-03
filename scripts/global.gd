extends Node
class_name ESGlobal

@export var _player_score: int
enum PlayMode {
    DEFAULT, RANDOM
}
@export var play_mode : PlayMode = PlayMode.DEFAULT
@export var random_seed: int

func get_score() -> int:
    return _player_score

func set_score(new_score:int):
    _player_score = new_score

func _ready() -> void:
    _player_score = 0
