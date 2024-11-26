extends usable

func use_object():
    get_tree().current_scene.objectiveGotten = true
    queue_free()
