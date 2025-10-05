extends Node2D
class_name Collection

signal bone_collected(bone_name: String)

@export var gameState: GameState

@export var numberOfDinoAreas: int

var currentCompletetDinoAreas = 0

func checkIfCompleteted():
    if currentCompletetDinoAreas >= 0:
        gameState.setCollectionCompleted()
        
func _on_dino_area_on_area_complete() -> void:
    currentCompletetDinoAreas += 1
    checkIfCompleteted()

func _on_game_state_bone_collected(bone_name: String) -> void:
    bone_collected.emit(bone_name)
