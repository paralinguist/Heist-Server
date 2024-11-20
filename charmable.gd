class_name charmable
extends CharacterBody2D

var id := -1
var item_type := "default"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    id = Global.next_id
    Global.next_id += 1
    print(id)
    add_to_group(str(id))
    add_to_group("Charmable")

func use(player: String, action: String):
    pass


func get_actions() -> Array[String]:
    return ["charm"]
