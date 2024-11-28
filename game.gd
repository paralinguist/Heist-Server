extends Node2D


const new_player_res: Resource = preload("res://default_player.tscn")
var player_lookup : Dictionary = {}
var heat := 0.0
var objectiveGotten := false
@export var all_levels : Array[String] = ["default_level_tiles"]
var last_level : String = "res://default_level_tiles.tscn"

func new_level():
    var new_level_string = "res://" + all_levels[randi()%all_levels.size()] + ".tscn"
    while new_level_string == last_level:
        new_level_string = "res://" + all_levels[randi()%all_levels.size()] + ".tscn"
    last_level = new_level_string
    var new_level_res := load(new_level_string)
    var new_level = new_level_res.instantiate()
    for c in $TileMap.get_children():
        c.queue_free()
    $TileMap.add_child(new_level)
    new_level.scale = Vector2(2, 2)
    for p in $Players.get_children():
        p.position = Vector2(48, 48)
    $Timer.start()
    heat = 0.0
    objectiveGotten = false
    get_tree().paused = false
    $UI/Control/VBoxContainer2.visible = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    $WebSocketServer.connect("new_player", create_new_player)
    $WebSocketServer.connect("move", move_player)
    $WebSocketServer.connect("action", take_action)
    $WebSocketServer.connect("heat_up", heat_up)
    $WebSocketServer.connect("movement_lock_toggle", movement_lock_toggle)
    new_level()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    process_player_sight()
    heat = clamp(heat, 0.0, 100.0)
    $UI/Control/VBoxContainer/ProgressBar.value = heat
    $UI/Control/VBoxContainer/Label.text = str(floor($Timer.time_left/60))+ ":"+str(int($Timer.time_left) % 60)
    $UI/Control/ColorRect.material.set("shader_parameter/heat", heat)
    if heat >= 100:
        get_tree().paused = true
        $UI/Control/VBoxContainer2.visible = true
        $UI/Control/VBoxContainer2/Label2.text = "You Lose!"

func process_player_sight():
    $TileMap.get_child(0).material.set("shader_parameter/override", true)
    for c in range($Players.get_child_count()):
        $TileMap.get_child(0).material.get("shader_parameter/positions")[c] = $Players.get_child(c).global_position
        $TileMap.get_child(0).material.get("shader_parameter/threshold")[c] = 150.0
    for nc in range($Players.get_child_count(), 5):
        $TileMap.get_child(0).material.get("shader_parameter/threshold")[nc] = 0.0

func move_player(role: String, direction: int, send_env: bool):
    if not player_lookup[role].movelock:
        player_lookup[role].move(direction)
        if send_env:
            $WebSocketServer.send_role_environment(role, player_lookup[role].get_local_env())

func create_new_player(role: String):
    if not role in player_lookup:
        var new_player = new_player_res.instantiate()
        $Players.add_child(new_player)
        new_player.position = Vector2(-1, -1)
        var all_spawners = get_tree().get_nodes_in_group("spawn")
        for s in all_spawners:
            if s.forplayer == role:
                new_player.position = s.global_position
        if new_player.position == Vector2(-1, -1):
            if all_spawners.size() > 0:
                all_spawners.shuffle()
                new_player.position = all_spawners[0].global_position
        player_lookup[role] = new_player
        new_player.role = role
        new_player.dont_be_inside()

func take_action(role: String, item_id: String, action: String):
    get_tree().call_group(str(item_id), "use", role, action)

func  send_result(role: String, type: String, id: int, data: String):
    $WebSocketServer.send_role_result(role, type, id, data)

func heat_up(amount: int):
    heat += amount

func movement_lock_toggle(role: String, is_locked: bool):
    player_lookup[role].movelock = is_locked

func get_addresses_around_item(item_id: String):
    if get_tree().get_nodes_in_group(str(item_id)).size() > 0:
        var tile_id: Vector2i = $TileMap.get_child(0).local_to_map(get_tree().get_first_node_in_group(str(item_id)).global_position)
        if tile_id != null:
            return $TileMap.get_child(0).get_hackables_in_radius(tile_id, 32)

#Types: door, safe, camera, guard, laser, file, terminal, blueprint, objective
func get_type_of_item(item_id):
    if item_id != "-1":
        var item = get_tree().get_first_node_in_group(str(item_id))
        return get_tree().get_first_node_in_group(str(item_id)).item_type

func get_serial_number(item_id):
    var item = get_tree().get_first_node_in_group(str(item_id))
    if item and item.is_pickable:
        return get_tree().get_first_node_in_group(str(item_id)).serial_data
    else:
        return "not pickable!"

func get_employee_info(item_id):
    var item = get_tree().get_first_node_in_group(str(item_id))
    if item.item_type == "guard":
        return get_tree().get_first_node_in_group(str(item_id)).employee_info
    else:
        return "not a guard!"

func get_all_employee_info():
    var active_guards : Array
    for guard in get_tree().get_nodes_in_group("Charmable"):
        active_guards.append(guard.employee_info)
    return active_guards

func get_all_serials():
    var serials : Array
    for item in get_tree().get_nodes_in_group("Pickable"):
        serials.append({"serial":item.serial_data["serial"], "brand":item.serial_data["brand"]})
    return serials
            
func play_lockpick():
    $LockpickMusic.volume_db = 0

func _on_timer_timeout() -> void:
    get_tree().paused = true
    $UI/Control/VBoxContainer2.visible = true
    $UI/Control/VBoxContainer2/Label2.text = "You Lose!"


func _on_win_timer_timeout() -> void:
    get_tree().paused = true
    $UI/Control/VBoxContainer2.visible = true
    $UI/Control/VBoxContainer2/Label2.text = "You Win!"


func _on_button_pressed() -> void:
    new_level()
