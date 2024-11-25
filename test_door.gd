extends hackpickable

var closed := true
var locked := true
var lock_info := {}

func _ready() -> void:
    super()
    item_type = "door"

func use(player: String, action: String):
    super(player, action)
    if action == "pick" and player == "lockpick":
        disable_object()
        toggle_state()

func disable_object():
    locked = false

func get_status():
    return locked
    
func toggle_state():
    locked = false
    print("toggling door")
    if closed and !locked:
        closed = false
        $Sprite2D.play("Open")
        $CollisionShape2D.disabled = true
        if has_node("LightOccluder2D"):
            $LightOccluder2D.occluder_light_mask = 0
        $Sprite2D2.visible = false
    else:
        closed = true
        $Sprite2D.play("Closed")
        $CollisionShape2D.disabled = false
        if has_node("LightOccluder2D"):
            $LightOccluder2D.occluder_light_mask = 1
        $Sprite2D2.visible = true

func get_actions() -> Array[String]:
    if locked:
        return ["hack", "pick"]
    else:
        return [""]
