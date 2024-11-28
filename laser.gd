extends hackpickable
var searching := true
var rot_speed := 10.0

func _ready() -> void:
    is_pickable = false
    super()
    item_type = "laser"


func use(player: String, action: String):
    #player may be used for verification in future
    if action in ["hack"]:
        disable_object()

func disable_object():
    searching = false
    $AudioStreamPlayer.stop()
    $CollisionShape2D.queue_free()
    self.visible = false


func get_actions() -> Array[String]:
    return ["hack"]


func _on_area_entered(area: Area2D) -> void:
    $AudioStreamPlayer.play()
    get_tree().current_scene.heat_up(8)
