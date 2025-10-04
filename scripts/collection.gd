extends Node2D
class_name Collection

@export var toolbelt: Toolbelt

@export var spawnPoint: Node2D
@export var collection: Node
@export var prefab: PackedScene

var aktiveBones = {}

var selectedBone: CollectionBone = null

func _ready() -> void:
	for i in range(20):
		var newBode: CollectionBone = prefab.instantiate()
		newBode.position = spawnPoint.position
		newBode.collection = self
		collection.add_child(newBode)
		
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			performAktion()

func _process(_delta: float):
	if selectedBone != null:
		var posMouse = get_global_mouse_position()
		selectedBone.position = posMouse

func performAktion(): 
	if selectedBone == null:
		pickUpBone()
	else:
		dropBone()
	

func pickUpBone():
	var canndidate = findBestBone()
	if canndidate != null:
		selectedBone = canndidate

func dropBone():
	if selectedBone != null:
		selectedBone = null

func findBestBone(): 
	var canndidate: CollectionBone = null
	for boneId in aktiveBones.keys():
		var bone: CollectionBone = aktiveBones[boneId]
		if canndidate == null:
			canndidate = bone
		else:
			if canndidate.z_index < bone.z_index:
				canndidate = bone
	return canndidate

func add_bone(newBone: CollectionBone):
	aktiveBones[newBone.get_instance_id()] = newBone

func remove_bone(newBone: CollectionBone):
	aktiveBones.erase(newBone.get_instance_id())
