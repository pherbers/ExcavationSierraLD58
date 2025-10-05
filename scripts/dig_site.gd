extends Node2D

class_name DigSite

var dig_layers: Array[TileMapLayer]
var object_layers: Array[TileMapLayer]
@onready var flag_layer: TileMapLayer = $Flags/TileMapLayer
@export var bounds: Rect2i

@export var shovel_masks: Array[Texture2D]
@export var trowel_masks: Array[Texture2D]
@export var brush_mask: Texture2D
var _shovel_cells_west: Array[Vector3i]
var _shovel_cells_north: Array[Vector3i]
var _shovel_cells_east: Array[Vector3i]
var _shovel_cells_south: Array[Vector3i]
var _trowel_cells_e: Array[Vector3i]
var _trowel_cells_s: Array[Vector3i]
var _trowel_cells_w: Array[Vector3i]
var _trowel_cells_n: Array[Vector3i]
var _brush_cells: Array[Vector3i]

var _dig_queue: Array[DigInstruction] = []
var _dig_queue_dirty = false

var is_brushing = false
var brush_time = 100
var _brush_timer = 0.
var _brush_chance = 0.

var _bone_positions: Dictionary[String, Vector3i]

signal hit_bone
signal brush_used

@onready var brush_sound = $BrushSound as AudioStreamPlayer

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
    _shovel_cells_west  = read_mask(shovel_masks[0])
    _shovel_cells_south = read_mask(shovel_masks[1])
    _shovel_cells_east  = read_mask(shovel_masks[2])
    _shovel_cells_north = read_mask(shovel_masks[3])
    
    _trowel_cells_e = read_mask(trowel_masks[0])
    _trowel_cells_s = read_mask(trowel_masks[1])
    _trowel_cells_w = read_mask(trowel_masks[2])
    _trowel_cells_n = read_mask(trowel_masks[3])
    
    _brush_cells = read_mask(brush_mask)
    
    for t in $DigLayers.find_children("*", "TileMapLayer"):
        dig_layers.append(t)
        
    dig_layers.sort_custom(func (t1, t2): return t1.z_index > t2.z_index)
    dig_layers.pop_back()  # remove bedrock
    
    for t in $ObjectLayers.find_children("*", "TileMapLayer"):
        object_layers.append(t)
        
    object_layers.sort_custom(func (t1, t2): return t1.z_index > t2.z_index)
    
    for object_layer_index in object_layers.size():
        var object_layer = object_layers[object_layer_index]
        for cell in object_layer.get_used_cells():
            var data = object_layer.get_cell_tile_data(cell)
            if data == null or not data.has_custom_data("ObjectID"):
                continue
            var objname = data.get_custom_data("ObjectID")
            _bone_positions[objname] = Vector3i(cell.x, cell.y, object_layer_index)
    
    print("Dig Site prepared, it is " + str(len(dig_layers)) + " layers deep")

func _process(_delta: float) -> void:
    if is_brushing:
        _brush_timer += _delta * 1000
    if is_brushing and _brush_timer > brush_time:
        dig_brush(dig_layers[0].local_to_map(dig_layers[0].get_local_mouse_position()))
        _brush_timer = 0
        brush_used.emit()
        if !brush_sound.playing:
            brush_sound.play()
                
    var ct = Time.get_ticks_msec()
    if _dig_queue_dirty:
        _dig_queue.sort_custom(func(d1,d2): return d1.time > d2.time)
        _dig_queue_dirty = false
        
    var _hitBone = false
    while _dig_queue.size() > 0:
        var di = _dig_queue.back()
        if ct > di.time:
            _dig_queue.pop_back()
            var result = dig_tile(di.pos, di.max_depth)
            if result == DigResult.HitBone:
                print("Hit Bone at " + str(di.pos))
                _hitBone = true
        else:
            break
    if _hitBone:
        # stop digging!
        _dig_queue.clear()
        hit_bone.emit()
        
func dig_shovel(pos: Vector2i, dir: int) -> DigResult:
    # find first available layer
    var dig_layer_index = -1

    for layer_index in dig_layers.size():
        var layer = dig_layers[layer_index]
        if layer.get_cell_tile_data(pos):
            dig_layer_index = layer_index
            break
    
    if dig_layer_index == -1:
        return DigResult.NoOp
    
    print("Digging at " + str(pos) + " with shovel at depth " + str(dig_layer_index))
    
    for pd in get_shovel_tiles(dir):
        var p = Vector2i(pd.x, pd.y)
        var delay: float = pd.z
        queue_dig_tile(p + pos, delay / 32., dig_layer_index)
    return DigResult.OK

func dig_trowel(pos: Vector2i, dir: int) -> DigResult:
    # find first available layer
    var dig_layer_index = -1

    for layer_index in dig_layers.size():
        var layer = dig_layers[layer_index]
        if layer.get_cell_tile_data(pos):
            dig_layer_index = layer_index
            break
    
    if dig_layer_index == -1:
        return DigResult.NoOp
    
    print("Digging at " + str(pos) + " with shovel at depth " + str(dig_layer_index))
    
    for pd in get_trowel_tiles(dir):
        var p = Vector2i(pd.x, pd.y)
        var delay: float = pd.z
        queue_dig_tile(p + pos, delay / 32., dig_layer_index)
    return DigResult.OK

func dig_brush(pos: Vector2i):
    for pd in _brush_cells:
        var p = Vector2i(pd.x,pd.y) + pos
        brush_tile(Vector3i(p.x, p.y, pd.z))
                
    _brush_chance += 0.01

func brush_tile(p: Vector3i) -> DigResult:
    var pos = Vector2i(p.x, p.y)
    var strength = p.z
    
    var base_random = randf() * strength
    if base_random > _brush_chance:
        return DigResult.NoOp

    var dig_layer_index = -1
    var brushing_bone = false
    for layer_index in dig_layers.size():
        if object_layers.size() > layer_index:
            var obj_layer = object_layers[layer_index]
            if obj_layer.get_cell_tile_data(pos):
                dig_layer_index = layer_index
                brushing_bone = true
                break
        var l = dig_layers[layer_index]
        if l.get_cell_tile_data(pos):
            dig_layer_index = layer_index
            break
            
    # Check neighborhood
    var layer = dig_layers[dig_layer_index]
    var r = 0
    if brushing_bone:
        r = 0.2
    else:
        var neighbours = [Vector2i(-1,-1), Vector2i(-1,0), Vector2i(-1,1), Vector2i(0,1), Vector2i(1,1), Vector2i(1,0), Vector2i(1,-1), Vector2i(0,-1)]
        var n_count = 0
        for n in neighbours:
            if layer.get_cell_tile_data(pos + n):
                n_count += 1
        
        match n_count:
            8,7,6,5: r = 0.
            4:     r = 0.05
            3:     r = max(0.2, r)
            2:     r = max(0.5, r)
            1:     r = max(0.8, r)
            0:     r = max(1., r)
            
    if randf() < r:
        layer.set_cells_terrain_connect([pos], 0, -1, false)
        flag_layer.set_cell(pos, -1)
        _brush_chance = 0.
        return DigResult.OK
    else:
        return DigResult.NoOp

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
    var hitBone = false
    for layer_index in dig_layers.size():
        
        if layer_index > max_depth and max_depth >= 0:
            return DigResult.NoOp
            
        if object_layers.size() > layer_index:
            var obj_layer = object_layers[layer_index]
            if obj_layer.get_cell_tile_data(pos):
                hitBone = true
        var layer = dig_layers[layer_index]
        if layer.get_cell_tile_data(pos):
            dig_layer_index = layer_index
            break

    if dig_layer_index == -1:
        return DigResult.NoOp
        
    var diglayer = dig_layers[dig_layer_index]
    diglayer.set_cell(pos, -1)
    diglayer.set_cells_terrain_connect([pos], 0, -1, false)
    
    flag_layer.set_cell(pos, -1)
    
    if hitBone:
        return DigResult.HitBone
    return DigResult.OK

func take_object(pos: Vector2i) -> String:
    if not bounds.has_point(pos):
        return ""
    
    var theObj = ""
    for layer_index in dig_layers.size():
        if object_layers.size() > layer_index:
            var obj_layer = object_layers[layer_index]
            if obj_layer == null:
                break
            var tile_data = obj_layer.get_cell_tile_data(pos)
            if tile_data and tile_data.has_custom_data("ObjectID"):
                theObj = tile_data.get_custom_data("ObjectID")
                break
        var layer = dig_layers[layer_index]
        if layer.get_cell_tile_data(pos):
            break
    
    if theObj == "":
        return ""
    
    var closed = []
    var take_q = [pos]
    while not take_q.is_empty():
        var currentPos = take_q.pop_back()
        
        var obj_pos = find_top_object(currentPos)
        if obj_pos.z == -1:
            continue
        if obj_pos in closed:
            continue
        var obj_layer = object_layers[obj_pos.z]
        var obj_data = obj_layer.get_cell_tile_data(Vector2i(obj_pos.x, obj_pos.y))
        if obj_data.has_custom_data("ObjectID"):
            if theObj != obj_data.get_custom_data("ObjectID"):
                continue
        if dig_layers[obj_pos.z].get_cell_tile_data(Vector2i(obj_pos.x, obj_pos.y)):
            print(str(theObj) + " is stuck...")
            return ""
        closed.append(obj_pos)
        take_q.append_array(obj_layer.get_surrounding_cells(currentPos))
    
    print(str(theObj) + " is free to be picked up")
    
    for obj_pos in closed:
        var obj_layer = object_layers[obj_pos.z]
        obj_layer.erase_cell(Vector2i(obj_pos.x, obj_pos.y))
    
    _bone_positions.erase(theObj)
    
    return theObj

func place_multi_flag(pos: Vector2i):
    var cells = get_brush_tiles()
    for c in cells:
        place_flag(Vector2i(c.x, c.y) + pos)
    
func place_flag(pos: Vector2i):
    if not bounds.has_point(pos):
        return DigResult.NoOp
    var top_obj = find_top_object(pos, true)
    if top_obj.z >= 0:
        flag_layer.set_cell(pos, 0, Vector2i.ZERO)
    else:
        flag_layer.set_cell(pos, 0, Vector2i(1,0))
    return DigResult.OK

func find_top_object(pos: Vector2i, ignore_dig_layer=false) -> Vector3i:
    for layer_index in dig_layers.size():
        if object_layers.size() > layer_index:
            var obj_layer = object_layers[layer_index]
            var tile_data = obj_layer.get_cell_tile_data(pos)
            if tile_data:
                return Vector3i(pos.x, pos.y, layer_index)
        var layer = dig_layers[layer_index]
        if layer.get_cell_tile_data(pos) and not ignore_dig_layer:
            break
    return Vector3i(pos.x, pos.y, -1)

func get_closest_bone_pos(pos: Vector2i) -> Vector3i:
    var top_obj = find_top_object(pos, true)
    if top_obj.z >= 0:
        return top_obj
    var closest_pos = Vector3i(-1,-1,-1)
    var closest_dist = INF
    for bone_name in _bone_positions:
        var bone_pos = _bone_positions[bone_name]
        var dist = (pos - Vector2i(bone_pos.x, bone_pos.y)).length()
        if dist < closest_dist:
            closest_pos = bone_pos
            closest_dist = dist
            
    return closest_pos

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
    
func get_trowel_tiles(trowel_dir: int) -> Array[Vector3i]:
    match(trowel_dir):
        0: return _trowel_cells_n
        1: return _trowel_cells_e
        2: return _trowel_cells_s
        3: return _trowel_cells_w
    return _trowel_cells_n

func get_brush_tiles() -> Array[Vector3i]:
    return _brush_cells

func getTileForMousePos() -> Vector2i:
    return dig_layers[0].local_to_map(dig_layers[0].get_local_mouse_position())

func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        if is_brushing:
            _brush_timer += event.velocity.length() / 10.
