extends Node2D

var layers: Array[TileMapLayer]
var bounds: Rect2i

func _ready() -> void:
    bounds = Rect2i()
    for t in find_children("*", "TileMapLayer"):
        layers.append(t)
        bounds = bounds.expand((t as TileMapLayer).get_used_rect().end)
        bounds = bounds.expand((t as TileMapLayer).get_used_rect().position)
        
    layers.sort_custom(func (t): return t.z_index)
    
    print("Dig Site prepared, it is " + str(len(layers)) + " layers deep")


func dig_circle(pos: Vector2i, radius: int):
    # find first available layer
    var dig_layer_index = -1

    for layer_index in layers.size():
        var layer = layers[layer_index]
        if layer.get_cell_tile_data(pos):
            dig_layer_index = layer_index
            break
    
    if dig_layer_index == -1:
        return
    
    print("Digging at " + str(pos) + " with radius "  + str(radius) + " at depth " + str(dig_layer_index))
    
    var xmin = max(pos.x - radius, bounds.position.x)
    var ymin = max(pos.y - radius, bounds.position.y)
    var xmax = min(pos.x + radius, bounds.end.x)
    var ymax = min(pos.y + radius, bounds.end.y)
    for x in range(xmin, xmax):
        for y in range(ymin, ymax):
            var p = Vector2i(x,y)
            if (p - pos).length() < radius:
                dig_tile(p, dig_layer_index)

#func queue_dig_tile(pos, time):
#    var timer = get_tree().create_timer(time)
#    timer.timeout += dig_tile()
            
func dig_tile(pos: Vector2i, max_depth=-1) -> bool:
    if not bounds.has_point(pos):
        return false
    var dig_layer_index = -1
    for layer_index in layers.size():
        var layer = layers[layer_index]
        if layer_index > max_depth:
            return false
        if layer.get_cell_tile_data(pos):
            dig_layer_index = layer_index
            break

    if dig_layer_index == -1:
        return false
        
    var diglayer = layers[dig_layer_index]
    diglayer.set_cell(pos, -1)
    diglayer.set_cells_terrain_connect([pos], 0, -1, false)
    
    return true

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
            var tile = layers[0].local_to_map(layers[0].get_local_mouse_position())
            dig_circle(tile, 4)
