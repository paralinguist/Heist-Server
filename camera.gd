extends StaticBody2D
var searching := true
var id := -1
var rot_speed := 5.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    id = Global.next_id
    Global.next_id += 1
    print(id)
    add_to_group(str(id))
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if searching:
        $PlayerCapture.rotation += TAU*delta/rot_speed

func use(player: String, action: String):
    #player may be used for verification in future
    if action in ["hack"]:
        disable_cam()

func disable_cam():
    searching = false
    $PlayerCapture.queue_free()
    $AudioStreamPlayer.stop()


func get_actions() -> Array[String]:
    return ["hack"]


func _on_player_capture_body_entered(body: Node2D) -> void:
    print("ALERT")
    $AudioStreamPlayer.play()
