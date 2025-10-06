extends Sprite2D

@export var sprite: Sprite2D
@export var defaultTexture: Texture2D
@export var highlightedTexture: Texture2D

var isHighlight: bool = false

func aktive():
    isHighlight = true
    sprite.texture = highlightedTexture
    
func deaktive():
    isHighlight = false
    sprite.texture = defaultTexture
