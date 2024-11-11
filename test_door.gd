extends StaticBody2D

var closed := true
var locked := true
var id := -1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    id = Global.next_id
    Global.next_id += 1
    print(id)
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func unlock_door():
    locked = false

func toggle_state():
    if closed and !locked:
        closed = false
        $Sprite2D.play("Open")
        $CollisionShape2D.disabled = true
        $LightOccluder2D.occluder_light_mask = 0
        $Sprite2D2.visible = false
    else:
        closed = true
        $Sprite2D.play("Closed")
        $CollisionShape2D.disabled = false
        $LightOccluder2D.occluder_light_mask = 1
        $Sprite2D2.visible = true

func get_actions() -> Array[String]:
    if locked:
        return ["hackable", "pickable"]
    elif closed:
        return ["open"]
    else:
        return ["close"]
