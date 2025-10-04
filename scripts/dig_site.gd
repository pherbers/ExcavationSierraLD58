extends Node2D

class_name DigSite

var dig_layers: Array[TileMapLayer]
var object_layers: Array[TileMapLayer]
var bounds: Rect2i

var _dig_queue: Array[DigInstruction] = []
var _dig_queue_dirty = false

class DigInstruction:
	var pos: Vector2i
	var time: float
	var max_depth: int
	
enum DigResult {
	NoOp = 0,
	OK = 1,
	HitBone = 2
}

func _ready() -> void:
	bounds = Rect2i()
	for t in $DigLayers.find_children("*", "TileMapLayer"):
		dig_layers.append(t)
		bounds = bounds.expand((t as TileMapLayer).get_used_rect().end)
		bounds = bounds.expand((t as TileMapLayer).get_used_rect().position)
		
	dig_layers.sort_custom(func (t): return t.z_index)
	
	for t in $ObjectLayers.find_children("*", "TileMapLayer"):
		object_layers.append(t)
		
	object_layers.sort_custom(func (t): return t.z_index)
	
	print("Dig Site prepared, it is " + str(len(dig_layers)) + " layers deep")

func _process(_delta: float) -> void:
	var ct = Time.get_ticks_msec()
	if _dig_queue_dirty:
		_dig_queue.sort_custom(func(d1,d2): return d1.time > d2.time)
		_dig_queue_dirty = false
	while _dig_queue.size() > 0:
		var di = _dig_queue.back()
		if ct > di.time:
			_dig_queue.pop_back()
			var result = dig_tile(di.pos, di.max_depth)
			if result == DigResult.HitBone:
				print("Hit Bone at " + str(di.pos))
				_dig_queue.clear()
		else:
			break

func dig_circle(pos: Vector2i, radius: int):
	# find first available layer
	var dig_layer_index = -1

	for layer_index in dig_layers.size():
		var layer = dig_layers[layer_index]
		if layer.get_cell_tile_data(pos):
			dig_layer_index = layer_index
			break
	
	if dig_layer_index == -1:
		return
	
	print("Digging at " + str(pos) + " with radius "  + str(radius) + " at depth " + str(dig_layer_index))
	
	var xmin = max(pos.x - radius, bounds.position.x)
	var ymin = max(pos.y - radius, bounds.position.y)
	var xmax = min(pos.x + radius, bounds.end.x) + 1
	var ymax = min(pos.y + radius, bounds.end.y) + 1
	for x in range(xmin, xmax):
		for y in range(ymin, ymax):
			var p = Vector2i(x,y)
			var dist_to_center = (p - pos).length()
			if dist_to_center - 0.1 <= radius:
				queue_dig_tile(p, pow(dist_to_center, 2) / 30., dig_layer_index)

func queue_dig_tile(pos, time=0., max_depth=-1):
	var ct = Time.get_ticks_msec()
	var di = DigInstruction.new()
	di.time = ct + (time * 1000.)
	di.pos = pos
	di.max_depth = max_depth
	_dig_queue_dirty = true
	_dig_queue.append(di)

func dig_tile(pos: Vector2i, max_depth=-1) -> DigResult:
	if not bounds.has_point(pos):
		return DigResult.NoOp
	var dig_layer_index = -1
	for layer_index in dig_layers.size():
		
		if layer_index > max_depth and max_depth >= 0:
			return DigResult.NoOp
			
		if object_layers.size() > layer_index:
			var obj_layer = object_layers[layer_index]
			if obj_layer.get_cell_tile_data(pos):
				return DigResult.HitBone
		var layer = dig_layers[layer_index]
		if layer.get_cell_tile_data(pos):
			dig_layer_index = layer_index
			break

	if dig_layer_index == -1:
		return DigResult.NoOp
		
	var diglayer = dig_layers[dig_layer_index]
	diglayer.set_cell(pos, -1)
	diglayer.set_cells_terrain_connect([pos], 0, -1, false)
	
	return DigResult.OK

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var tile = dig_layers[0].local_to_map(dig_layers[0].get_local_mouse_position())
			dig_circle(tile, 4)
