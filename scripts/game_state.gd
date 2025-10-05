extends Node

class_name GameState

signal bone_collected(bone_name: String)

func collect_bone(bone_name: String):
    print("Bone collected: " + bone_name)
    bone_collected.emit(bone_name)
