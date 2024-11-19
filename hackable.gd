extends Node

var id := -1
var mac_address : String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    id = Global.next_id
    Global.next_id += 1
    print(id)
    add_to_group(str(id))
    add_to_group("Hackable")
    mac_address = Global.generate_mac_address()
    add_to_group(mac_address)

func use(player: String, action: String):
    #player may be used for verification in future
    if action in ["hack"]:
        disable_object()

func disable_object():
    pass


func get_actions() -> Array[String]:
    return ["hack"]
