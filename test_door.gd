extends StaticBody2D

var closed := true
var locked := true
var lock_info := {}
var id := -1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    id = Global.next_id
    Global.next_id += 1
    lock_info = Global.get_lock_info()
    print(id)
    add_to_group(str(id))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func use(player: String, action: String):
    #player may be used for verification in future
    if action in ["hack", "pick"]:
        print("door hacked")
        unlock_door()
    elif action == "use":
        toggle_state()

func unlock_door():
    locked = false

func get_status():
    return locked
    
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
        return ["hack", "pick"]
    else:
        return ["use"]
