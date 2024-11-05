extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    process_player_sight()

func process_player_sight():
    $TileMap.get_child(0).material.set("shader_parameter/override", false)
    for c in range($Players.get_child_count()):
        $TileMap.get_child(0).material.get("shader_parameter/positions")[c] = $Players.get_child(c).global_position
        $TileMap.get_child(0).material.get("shader_parameter/threshold")[c] = 100.0
    for nc in range($Players.get_child_count(), 5):
        $TileMap.get_child(0).material.get("shader_parameter/threshold")[nc] = 0.0
