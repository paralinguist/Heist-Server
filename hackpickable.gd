class_name hackpickable
extends usable

var mac_address : String
var serial_data : Dictionary
var is_maze : bool = true
var is_hackable := true
var is_pickable := true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    super()
    if is_hackable:
        add_to_group("Hackable")
        mac_address = Global.generate_mac_address()
        add_to_group(mac_address)
    if is_pickable:
        add_to_group("Pickable")
        serial_data = Global.get_lock_info()

func use(player: String, action: String):
    #player may be used for verification in future
    if action in ["hack"]:
        disable_object()

func disable_object():
    pass


func get_actions() -> Array[String]:
    var all_actions = []
    if is_hackable:
        all_actions.append("hack")
    if is_pickable:
        all_actions.append("pick")
    return all_actions
