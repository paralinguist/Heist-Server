extends StaticBody2D

var locked := true
var id := -1
var to_read := "This is a test read. I don't know what to put here"
signal send_safe(role: String, type: String, id: int, data: String)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    id = Global.next_id
    Global.next_id += 1
    print(id)
    add_to_group(str(id))
    var par := get_tree().get_first_node_in_group("Parent")
    connect("send_safe", par.send_result)
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func use(player: String, action: String):
    #player may be used for verification in future
    if action in ["hack", "pick"]:
        unlock_door()
    elif action == "read":
        read_file(player)

func unlock_door():
    locked = false
    $Sprite2D.play("Open")
    $Sprite2D2.play("Open")

func read_file(player: String):
    if not locked:
        emit_signal("send_safe", player, "safe", id, to_read)

func get_actions() -> Array[String]:
    if locked:
        return ["hack", "pick"]
    else:
        return ["read"]
