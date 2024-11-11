extends Node2D


const new_player_res: Resource = preload("res://default_player.tscn")
var player_lookup : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    $WebSocketServer.connect("new_player", create_new_player)
    $WebSocketServer.connect("move", move_player)
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    process_player_sight()

func process_player_sight():
    $TileMap.get_child(0).material.set("shader_parameter/override", false)
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
        $Players.position = Vector2(32*(1+randi()%8)+16, 32*(1+randi()%8)+16)
        player_lookup[role] = new_player
        new_player.role = role
