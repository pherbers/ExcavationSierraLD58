extends Node2D

@export var tileMap: TileMapLayer

@export var damageTexture: Array[Texture2D]

func _ready() -> void:
    if ($/root/Global as ESGlobal).play_mode == ESGlobal.PlayMode.RANDOM:
        $TileMapLayer.enabled = false
        $TileMapLayerStego.enabled = true
        tileMap = $TileMapLayerStego
        $Exhibit.visible = false
        $ExhibitStego.visible = true

    var cells: Array[Vector2i] = tileMap.get_used_cells()
    for index: Vector2i in cells:
        var cell: TileData = tileMap.get_cell_tile_data(index)
        var sourcId = tileMap.get_cell_source_id(index)
        var atlasCoords = tileMap.get_cell_atlas_coords(index)
        var cellCustomData = cell.get_custom_data("ObjectID")
        var boneName = str(cellCustomData)

        var damages = BoneCollectionState.get_damages_for_bone(boneName)
        var dmgIndex = damages.find_custom(func(d): return d.atlas_id == sourcId and d.atlas_pos == atlasCoords)
        if dmgIndex != -1:
            var dmg = damages[dmgIndex]
            create_damage_viz(index, dmg.damage_type)

func create_damage_viz(pos: Vector2i, damage_type: int):
    var damageviz = Sprite2D.new()
    var tex = damageTexture[damage_type]
    damageviz.texture = tex
    damageviz.position = tileMap.map_to_local(pos)
    add_child(damageviz)
