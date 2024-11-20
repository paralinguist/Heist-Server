extends "res://hackable.gd"
var searching := true
var rot_speed := 5.0

func _ready() -> void:
    super()
    item_type = "camera"

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
    $PlayerCapture.queue_free()
    $AudioStreamPlayer.stop()


func get_actions() -> Array[String]:
    return ["hack"]

func _on_player_capture_body_entered(body: Node2D) -> void:
    print("ALERT")
    $AudioStreamPlayer.play()
