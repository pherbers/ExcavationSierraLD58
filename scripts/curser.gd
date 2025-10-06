extends Node2D
class_name Curser

@export var curserAnimator: AnimatedSprite2D

@export var toolbelt: Toolbelt
@onready var dig_site: DigSite = $/root/MainScene/DigSite
@onready var game_state: GameState = $/root/MainScene/GameState as GameState
@export var label:Label

var lastTool: Toolbelt.Tools = Toolbelt.Tools.Hand

var gpr_state: int = -1

func _ready() -> void:
    changeToHand()

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
            curserAnimator.play()
        elif !event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
            curserAnimator.stop()

func _process(_delta: float):
    var posMouse = get_global_mouse_position()
    position = posMouse
    
    var currentTool = toolbelt.currentTool;
    if currentTool != lastTool:
        lastTool = currentTool
        if currentTool == Toolbelt.Tools.Shovel:
            changeToShovel()
        elif currentTool == Toolbelt.Tools.Trowel:
            changeToTrowel()
        elif currentTool == Toolbelt.Tools.Brush:
            changeToBrush()
        elif currentTool == Toolbelt.Tools.Hand:
            changeToHand()
        elif currentTool == Toolbelt.Tools.GPR:
            changeToGPR()
            
    gpr_state = -1
    if currentTool == Toolbelt.Tools.GPR:
        var mouseTile = dig_site.getTileForMousePos()
        var closest_bone_pos = dig_site.get_closest_bone_pos(mouseTile, game_state.item_gpr_depth)
        var pos = Vector2i(closest_bone_pos.x, closest_bone_pos.y)
        var dist = (pos - mouseTile).length()
        if dist < 0.5:
            var soil_layer = dig_site.find_top_dig_layer(pos)
            var depth = closest_bone_pos.z - soil_layer.z
            match depth:
                0: 
                    gpr_state = 4
                1:
                    gpr_state = 5
                2:
                    gpr_state = 6
                3:
                    gpr_state = 7
                4:
                    gpr_state = 8
                _:
                    gpr_state = 8
        elif dist < 5.:
            gpr_state = 3
        elif dist < 15.:
            gpr_state = 2
        elif dist < 25.:
            gpr_state = 1
        else:
            gpr_state = 0
        curserAnimator.frame = gpr_state

func gpr_beep():
    print("Beep")
    var pitch = 1.
    match gpr_state:
        -1: return
        0: pitch = 1.
        1: pitch = 1.1
        2: pitch = 1.3
        3: pitch = 1.5
        4,5,6,7,8,_: pitch = 1.7
    $BeepSound.pitch_scale = pitch
    $BeepSound.play()

func changeToShovel():
    curserAnimator.visible = true
    curserAnimator.play("Shovel")
    curserAnimator.stop()
    curserAnimator.frame = 0
    label.text = "Shovel"
    label.visible = false
    
func changeToTrowel():
    curserAnimator.visible = true
    curserAnimator.play("Trowel")
    curserAnimator.stop()
    curserAnimator.frame = 0
    label.text = "Trowel"
    label.visible = false
    
func changeToBrush():
    curserAnimator.visible = true
    curserAnimator.play("Brush")
    curserAnimator.stop()
    curserAnimator.frame = 0
    label.text = "Brush"
    label.visible = false
    
func changeToHand():
    curserAnimator.visible = false
    curserAnimator.stop()
    curserAnimator.frame = 0
    label.text = "Hand"
    label.visible = false
    
func changeToGPR():
    curserAnimator.visible = true
    curserAnimator.play("GPR")
    curserAnimator.stop()
    curserAnimator.frame = 0
    label.text = "GPR"
    label.visible = false
    
    gpr_state = 0
    gpr_beep()

func _on_toolbelt_direction_has_changed(newDir: int) -> void:
    if newDir == 0:
        self.rotation_degrees = 45
    elif newDir == 1:
        self.rotation_degrees = 135
    elif newDir == 2:
        self.rotation_degrees = 225
    elif newDir == 3:
       self.rotation_degrees = 315
    else:
        self.rotation_degrees = 0
