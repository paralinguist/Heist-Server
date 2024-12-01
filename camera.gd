extends hackpickable
var searching := true
var rot_speed := 10.0

func _ready() -> void:
    is_pickable = false
    is_hackable = true
    super()
    item_type = "camera"
    add_to_group("Camera")
    add_to_group("Tiles")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if searching:
        $PlayerCapture.rotation += TAU*delta/rot_speed

func use(player: String, action: String):
    #player may be used for verification in future
    if action in ["hack"]:
        disable_object()

func disable_object():
    searching = false
    $PlayerCapture.limit = 0
    $AudioStreamPlayer.stop()

func enable_object():
    searching = true
    $PlayerCapture.limit = 275

func get_actions() -> Array[String]:
    return ["hack"]

func _on_player_capture_new_obj_collision(body: PhysicsBody2D) -> void:
    print("ALERT")
    $AudioStreamPlayer.play()
    get_tree().current_scene.heat_up(8)
