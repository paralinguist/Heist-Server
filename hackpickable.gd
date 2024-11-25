class_name hackpickable
extends usable

var hack_timer : Timer
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
        hack_timer = Timer.new()
        add_child(hack_timer)
        hack_timer.wait_time = 30.0
        hack_timer.one_shot = true
        hack_timer.connect("timeout", _on_timer_timeout)
    if is_pickable:
        add_to_group("Pickable")
        serial_data = Global.get_lock_info()

func _on_timer_timeout():
    enable_object()

func use(player: String, action: String):
    if action == "pick" and player == "lockpick":
        disable_object()
    elif action == "hack" and player == "hacker":
        hack_timer.start()
        disable_object()

func disable_object():
    pass

func enable_object():
    pass

func get_actions() -> Array[String]:
    var all_actions = []
    if is_hackable:
        all_actions.append("hack")
    if is_pickable:
        all_actions.append("pick")
    return all_actions
