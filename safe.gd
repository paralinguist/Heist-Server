extends "res://hackable.gd"

var locked := true
var to_read := "This is a test read. I don't know what to put here"
signal send_safe(role: String, type: String, id: int, data: String)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    super()
    var par := get_tree().get_first_node_in_group("Parent")
    connect("send_safe", par.send_result)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func use(player: String, action: String):
    #player may be used for verification in future
    super(player, action)
    if action == "pick":
        disable_object()
    elif action == "read":
        read_file(player)

func disable_object():
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
