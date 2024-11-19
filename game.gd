extends Node2D


const new_player_res: Resource = preload("res://default_player.tscn")
var player_lookup : Dictionary = {}
var heat := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    $WebSocketServer.connect("new_player", create_new_player)
    $WebSocketServer.connect("move", move_player)
    $WebSocketServer.connect("action", take_action)
    $WebSocketServer.connect("heat_up", heat_up)
    $WebSocketServer.connect("movement_lock_toggle", movement_lock_toggle)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    process_player_sight()
    heat = clamp(heat, 0.0, 100.0)
    $UI/Control/ProgressBar.value = heat
    $UI/Control/ColorRect.material.set("shader_parameter/heat", heat)

func process_player_sight():
    $TileMap.get_child(0).material.set("shader_parameter/override", true)
    for c in range($Players.get_child_count()):
        $TileMap.get_child(0).material.get("shader_parameter/positions")[c] = $Players.get_child(c).global_position
        $TileMap.get_child(0).material.get("shader_parameter/threshold")[c] = 150.0
    for nc in range($Players.get_child_count(), 5):
        $TileMap.get_child(0).material.get("shader_parameter/threshold")[nc] = 0.0

func move_player(role: String, direction: int, send_env: bool):
    player_lookup[role].move(direction)
    if send_env:
        $WebSocketServer.send_role_environment(role, player_lookup[role].get_local_env())

func create_new_player(role: String):
    if not role in player_lookup:
        var new_player = new_player_res.instantiate()
        $Players.add_child(new_player)
        $Players.position = Vector2(32*($Players.get_child_count())+16, 48)
        player_lookup[role] = new_player
        new_player.role = role
        new_player.dont_be_inside()

func take_action(role: String, item_id: int, action: String):
    get_tree().call_group(str(item_id), "use", role, action)

func  send_result(role: String, type: String, id: int, data: String):
    $WebSocketServer.send_role_result(role, type, id, data)

func heat_up(amount: int):
    heat += amount

func movement_lock_toggle(role: String, is_locked: bool):
    player_lookup[role].movelock = is_locked

func get_addresses_around_item(item_id: int):
    var tile_id: Vector2i = $TileMap.get_child(0).local_to_map(get_tree().get_first_node_in_group(str(item_id)).position)
    return $TileMap.get_child(0).get_hackables_in_radius(tile_id, 32)
