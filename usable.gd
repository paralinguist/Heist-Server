class_name usable
extends Node

var id := -1
var item_type := "default"
var tile_location : Vector2i
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    id = Global.next_id
    Global.next_id += 1
    print(id)
    add_to_group(str(id))
    add_to_group("Usable")

func use(player: String, action: String):
    #player may be used for verification in future
    if action in ["use"]:
        use_object()

func use_object():
    pass


func get_actions() -> Array[String]:
    return ["use"]
