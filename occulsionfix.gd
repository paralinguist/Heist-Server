extends TileMapLayer

const occl: Resource = preload("res://occluder.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    for pos in get_used_cells():
        var tile := get_cell_tile_data(pos)
        if tile and tile.terrain == 0:
            var newOccl = occl.instantiate()
            add_child(newOccl)
            newOccl.position = Vector2(32, 32) + pos*64.0
            var source_id = get_cell_source_id(pos)
            var source = tile_set.get_source(source_id) as TileSetAtlasSource
            var atlas_coords = get_cell_atlas_coords(pos)
            var rect = source.get_tile_texture_region(atlas_coords)
            var image = source.texture.get_image()
            var tile_image = image.get_region(rect)
            var texture = ImageTexture.create_from_image(tile_image)
            newOccl.texture = texture
            
        


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
