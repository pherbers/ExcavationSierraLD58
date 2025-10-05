extends Node

class_name GameState

signal bone_collected(bone_name: String)
signal collection_completed()

@export var isCollectionComplete = false

func collect_bone(bone_name: String):
    print("Bone collected: " + bone_name)
    bone_collected.emit(bone_name)
    
func setCollectionCompleted():
    if !isCollectionComplete:
        print("Collection is completed!")
        isCollectionComplete = true
        collection_completed.emit()
