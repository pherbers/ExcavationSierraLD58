extends Node2D
class_name Collection

signal bone_collected(bone_name: String)
signal on_bone_number_change(current:int, max:int)

@export var dinoAreas: Array[DinoArea]
@export var infoBox: Node2D
@export var priceLabel: Label
@export var damagedLabel: Label

@export var gameState: GameState

@export var numberOfDinoAreas: int

var currentCompletetDinoAreas = 0

func checkIfCompleteted():
    if currentCompletetDinoAreas >= dinoAreas.size():
        gameState.setCollectionCompleted()

func _on_dino_area_on_area_complete() -> void:
    currentCompletetDinoAreas += 1
    checkIfCompleteted()

func _on_game_state_bone_collected(bone_name: String) -> void:
    bone_collected.emit(bone_name)

func _process(_delta: float) -> void:
    var posMouse = get_global_mouse_position()

    var dinoPointer: DinoArea.Bone = null
    for area in dinoAreas:
        var bone = area.get_bone_at_world_pos(posMouse)
        if bone != null:
            dinoPointer = bone
            break

    if dinoPointer == null:
        infoBox.visible = false
    else:
        infoBox.visible = true
        var price = dinoPointer.countOfBonesDamaged * gameState.valueOfDamgedBone
        price += dinoPointer.countOfBonesUndamaged * gameState.valueOfUndamgedBone
        priceLabel.text = "Value: " + str(price) + "$"

        if dinoPointer.countOfBonesDamaged > 0:
            damagedLabel.text = "Damaged" + " Bone"
        else:
            damagedLabel.text = "Undamaged" + " Bone"

    infoBox.global_position = posMouse

func _on_dino_area_on_bone_number_chaneg(currentBones: int, maxBones: int) -> void:
    on_bone_number_change.emit(currentBones, maxBones)

func skip_all():
    for dinoArea in dinoAreas:
        dinoArea.revalAll()
