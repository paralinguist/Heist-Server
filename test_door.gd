extends hackpickable

var closed := true
var locked := true
var lock_info := {}

func _ready() -> void:
    super()
    item_type = "door"

func use(player: String, action: String):
    super(player, action)
    
func disable_object():
    print("disabling door")
    super()
    locked = false
    closed = false
    $Sprite2D.play("Open")
    $CollisionShape2D.disabled = true
    if has_node("LightOccluder2D"):
        $LightOccluder2D.occluder_light_mask = 0
    $Sprite2D2.visible = false
    $Sprite2D.visible = false

func enable_object():
    print("enabling door")
    super()
    locked = true
    closed = true
    $Sprite2D.play("Closed")
    $CollisionShape2D.disabled = false
    if has_node("LightOccluder2D"):
        $LightOccluder2D.occluder_light_mask = 1
    $Sprite2D2.visible = true
    $Sprite2D.visible = true

func get_status():
    return locked
    
func toggle_state():
    if closed and !locked:
        disable_object()
    else:
        enable_object()

func get_actions() -> Array[String]:
    if locked:
        return ["hack", "pick"]
    else:
        return [""]
