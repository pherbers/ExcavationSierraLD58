extends AudioStreamPlayer

@export var repeat_play = true
@export var time_between_plays = 60.
@export var first_stinger_after = 30.
var _timer: Timer

func _ready() -> void:
    _timer = Timer.new()
    add_child(_timer)
    _timer.one_shot = true
    _timer.wait_time = time_between_plays
    _timer.timeout.connect(play_it_again)
    finished.connect(_timer.start)
    _timer.start(first_stinger_after)

func play_it_again():
    if repeat_play:
        play()
