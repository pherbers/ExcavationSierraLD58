extends Node2D

class_name DigSite

var dig_layers: Array[TileMapLayer]
var object_layers: Array[TileMapLayer]
var bounds: Rect2i

@export var shovel_masks: Array[Texture2D]
var _shovel_cells_west: Array[Vector3i]
var _shovel_cells_north: Array[Vector3i]
var _shovel_cells_east: Array[Vector3i]
var _shovel_cells_south: Array[Vector3i]

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
    _shovel_cells_west = read_mask(shovel_masks[0])
    _shovel_cells_south = read_mask(shovel_masks[1])
    _shovel_cells_east = read_mask(shovel_masks[2])
    _shovel_cells_north = read_mask(shovel_masks[3])
    
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

func dig_shovel(pos: Vector2i):
    # find first available layer
    var dig_layer_index = -1

    for layer_index in dig_layers.size():
        var layer = dig_layers[layer_index]
        if layer.get_cell_tile_data(pos):
            dig_layer_index = layer_index
            break
    
    if dig_layer_index == -1:
        return
    
    print("Digging at " + str(pos) + " with shovel at depth " + str(dig_layer_index))
    
    for pd in get_shovel_tiles(0):
        var p = Vector2i(pd.x, pd.y)
        var delay: float = pd.z
        queue_dig_tile(p + pos, delay / 32., dig_layer_index)

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

func read_mask(mask: Texture2D) -> Array[Vector3i]:
    var img = mask.get_image()
    var mask_tiles: Array[Vector3i] = []
    var cx: int = - floor(img.get_width() - 1) / 2
    var cy: int = - floor(img.get_height() - 1) / 2
    for x in img.get_width():
        for y in img.get_height():
            var c = img.get_pixel(x, y)
            if c.b < 1.:
                var t = Vector3i(cx + x, cy + y, floor(c.b*16))
                mask_tiles.append(t)
    return mask_tiles

func get_shovel_tiles(shovel_dir: int) -> Array[Vector3i]:
    match(shovel_dir):
        0:
            return _shovel_cells_north
        1:
            return _shovel_cells_west
        2:
            return _shovel_cells_south
        3:
            return _shovel_cells_east
    return _shovel_cells_north

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
            var tile = dig_layers[0].local_to_map(dig_layers[0].get_local_mouse_position())
            dig_shovel(tile)
