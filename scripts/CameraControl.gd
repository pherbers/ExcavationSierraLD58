extends Camera2D

var moveVectorMouse: Vector2
var moveVectorKeys: Vector2
@export var scrollSpeed: float = 100
@export var scrollAreaWidth: int = 32
@onready var dig_site: DigSite = $/root/MainScene/DigSite as DigSite

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


func _process(delta):
    if moveVectorKeys.length_squared() > 0.01:
        position += moveVectorKeys.normalized() * delta * scrollSpeed
    else:
        position += moveVectorMouse.normalized() * delta * scrollSpeed
        
    if position.y > limit_bottom:
        position.y = limit_bottom
    elif position.y < limit_top:
        position.y = limit_top
    if position.x > limit_right:
        position.x = limit_right
    elif position.x < limit_left:
        position.x = limit_left
        
    print(position)


func _input(event):
    if event is InputEventMouseMotion:
        var mousePos = event.position
        var viewportSize = get_viewport().get_visible_rect().size
        moveVectorMouse = Vector2(0,0)
        if mousePos.x < scrollAreaWidth:
            moveVectorMouse.x -= 1;
        if mousePos.x > viewportSize.x - scrollAreaWidth:
            moveVectorMouse.x += 1;
        if mousePos.y < scrollAreaWidth:
            moveVectorMouse.y -= 1;
        if mousePos.y > viewportSize.y - scrollAreaWidth:
            moveVectorMouse.y += 1;
    if event is InputEventKey:
        var keyVec = Input.get_vector("CameraLeft", "CameraRight", "CameraUp", "CameraDown")
        moveVectorKeys = keyVec.clamp(Vector2(-1, -1), Vector2(1, 1))
        
