extends TileMapLayer

const occl: Resource = preload("res://occluder.tscn")

@export var safe_data: Array[String] = []


var scene_coords: Dictionary = {}

func _enter_tree():
  child_entered_tree.connect(_register_child)
  child_exiting_tree.connect(_unregister_child)

func _register_child(child):
  await child.ready
  var coords = local_to_map(to_local(child.global_position))
  scene_coords[coords] = child
  child.set_meta("tile_coords", coords)

func _unregister_child(child):
  scene_coords.erase(child.get_meta("tile_coords"))

func get_cell_scene(coords: Vector2i) -> Node:
  return scene_coords.get(coords, null)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    #wait for tile map to spawn before editting children from it
    await get_tree().process_frame
    var all_cells = get_used_cells()
    var safe_count = 0
    all_cells.sort()
    for pos in all_cells:
        var tile := get_cell_tile_data(pos)
        var scene := get_cell_scene(pos)
        if scene:
            if scene.is_in_group("Safe"):
                scene.to_read = safe_data[safe_count]
                safe_count += 1
            
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
