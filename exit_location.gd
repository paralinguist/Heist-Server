extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if get_overlapping_bodies().size() == get_tree().current_scene.player_lookup.size() and get_tree().current_scene.objectiveGotten:
        get_tree().current_scene.get_node("WinTimer").start()
