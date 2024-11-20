class_name WebSocketServer
extends Node

const UP: int = 3
const DOWN: int = 1
const LEFT: int = 2
const RIGHT: int = 0

var api_version = "1.02"

var directions = {"up":UP, "down":DOWN, "left":LEFT, "right":RIGHT}

const ACTION_SUCCESS := 0
const ACTION_FAILURE := 1
const ACTION_CANCELLED := 2

signal message_received(peer_id: int, message: String)
signal client_connected(peer_id: int)
signal new_player(peer_id: int, role: String)
signal client_disconnected(peer_id: int)
signal move(role: String, direction: int)
signal action(role: String, item_id: int, action: String)
signal heat_up(amount: int)
signal movement_lock_toggle(role: String, is_locked: bool)

## The port the server will listen on.
const PORT = 9876

@export var handshake_timeout := 3000

var tcp_server := TCPServer.new()
var socket := WebSocketPeer.new()
var pending_peers: Array[PendingPeer] = []
var peers: Dictionary
var players: Dictionary

class PendingPeer:
    var connect_time: int
    var tcp: StreamPeerTCP
    var connection: StreamPeer
    var ws: WebSocketPeer

    func _init(p_tcp: StreamPeerTCP) -> void:
        tcp = p_tcp
        connection = p_tcp
        connect_time = Time.get_ticks_msec()

func log_message(message: String) -> void:
    var time := "[color=#aaaaaa] %s |[/color] " % Time.get_time_string_from_system()
    print(time + message + "\n")


func _ready() -> void:
    if tcp_server.listen(PORT) != OK:
        log_message("Unable to start server.")
        set_process(false)

func _process(_delta: float) -> void:
    poll()
    """
    while tcp_server.is_connection_available():
        var conn: StreamPeerTCP = tcp_server.take_connection()
        assert(conn != null)
        pending_peers.append(PendingPeer.new(conn))
        socket.accept_stream(conn)

    socket.poll()
    """

    if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
        while socket.get_available_packet_count():
            log_message(socket.get_packet().get_string_from_ascii())

func poll() -> void:
    if not tcp_server.is_listening():
        return

    while tcp_server.is_connection_available():
        var conn: StreamPeerTCP = tcp_server.take_connection()
        assert(conn != null)
        pending_peers.append(PendingPeer.new(conn))

    var to_remove := []

    for p in pending_peers:
        if not _connect_pending(p):
            if p.connect_time + handshake_timeout < Time.get_ticks_msec():
                print("Removing: " + str(p))
                # Timeout.
                to_remove.append(p)
            continue  # Still pending.

        to_remove.append(p)

    for r: RefCounted in to_remove:
        pending_peers.erase(r)

    to_remove.clear()

    for id: int in peers:
        var p: WebSocketPeer = peers[id]
        p.poll()

        if p.get_ready_state() != WebSocketPeer.STATE_OPEN:
            client_disconnected.emit(id)
            to_remove.append(id)
            if id in players:
                print(players[id] + " has disconnected")
                players.erase(id)
            continue

        while p.get_available_packet_count():
            message_received.emit(id, get_message(id))

    for r: int in to_remove:
        peers.erase(r)
    to_remove.clear()

func _connect_pending(p: PendingPeer) -> bool:
    if p.ws != null:
        # Poll websocket client if doing handshake.
        p.ws.poll()
        var state := p.ws.get_ready_state()
        if state == WebSocketPeer.STATE_OPEN:
            var id := randi_range(2, 1 << 30)
            peers[id] = p.ws
            client_connected.emit(id)
            print("Client connected: " + str(id))
            return true  # Success.
        elif state != WebSocketPeer.STATE_CONNECTING:
            return true  # Failure.
        return false  # Still connecting.
    elif p.tcp.get_status() != StreamPeerTCP.STATUS_CONNECTED:
        return true  # TCP disconnected.
    # TCP is ready, create WS peer.
    p.ws = _create_peer()
    p.ws.accept_stream(p.tcp)
    return false  # WebSocketPeer connection is pending.

func stop() -> void:
    tcp_server.stop()
    pending_peers.clear()
    peers.clear()

func _exit_tree() -> void:
    socket.close()
    tcp_server.stop()

func send(peer_id: int, message: String) -> int:
    var type := typeof(message)
    if peer_id <= 0:
        # Send to multiple peers, (zero = broadcast, negative = exclude one).
        for id: int in peers:
            if id == -peer_id:
                continue
            peers[id].put_packet(message.to_utf8_buffer())
        return OK

    assert(peers.has(peer_id))
    var socket: WebSocketPeer = peers[peer_id]
    if type == TYPE_STRING:
        return socket.send_text(message)
    return socket.send(var_to_bytes(message))

func get_message(peer_id: int) -> Variant:
    assert(peers.has(peer_id))
    var socket: WebSocketPeer = peers[peer_id]
    if socket.get_available_packet_count() < 1:
        return null
    var pkt: PackedByteArray = socket.get_packet()
    if socket.was_string_packet():
        var message = pkt.get_string_from_utf8()
        if message.begins_with("join|"):
            var player_role = message.right(len(message) - 5)
            emit_signal("new_player", player_role)
            print(player_role + " has joined!")
            players[peer_id] = player_role
        else:
            var heist_instruction = JSON.new()
            if heist_instruction.parse(message) == OK:
                var instruction = heist_instruction.data
                if instruction["action"] == "join":
                    print(instruction["role"] + " has joined!" + "(API: " + instruction["version"] + ")")
                    players[peer_id] = instruction["role"]
                    emit_signal("new_player", instruction["role"])
                elif instruction["action"] == "move":
                    move.emit(instruction["role"], directions[instruction["direction"]], true)
                elif instruction["action"] in ["hack", "pick", "use", "read"]:
                    if instruction["action"] == "hack":
                        match instruction["state"]:
                            "begin":
                                var addresses = get_parent().get_addresses_around_item(instruction["item"])
                                var response = {"type": "begin_action", "id": instruction["item"], "data": addresses}
                                send(peer_id, JSON.stringify(response))
                                emit_signal("movement_lock_toggle", instruction["role"], true)
                            "success":
                                emit_signal("action", instruction["role"], instruction["item"], instruction["action"])
                                emit_signal("movement_lock_toggle", instruction["role"], false)
                            "failed":
                                emit_signal("heat_up", 8)
                                emit_signal("movement_lock_toggle", instruction["role"], false)
                            "cancel":
                                emit_signal("heat_up", 2)
                                emit_signal("movement_lock_toggle", instruction["role"], false)
                    elif instruction["action"] == "pick":
                        match instruction["state"]:
                            "begin":
                                #Currently sends random lock info, should be pre-set
                                var response = {"type": "begin_action", "id": instruction["item"], "data": Global.get_lock_info()}
                                send(peer_id, JSON.stringify(response))
                                emit_signal("movement_lock_toggle", instruction["role"], true)
                            "success":
                                emit_signal("action", instruction["role"], instruction["item"], instruction["action"])
                                emit_signal("movement_lock_toggle", instruction["role"], false)
                            "failed":
                                emit_signal("heat_up", 8)
                                emit_signal("movement_lock_toggle", instruction["role"], false)
                            "cancel":
                                emit_signal("heat_up", 2)
                                emit_signal("movement_lock_toggle", instruction["role"], false)
                    elif instruction["action"] == "use":
                        if get_parent().get_type_of_item() == "file":
                            #stub - returns dummy set of guards
                            var guard_data = Global.get_guards(8)
                            var response = {"type": "earpiece_info", "id": instruction["item"], "data": guard_data}
                            send(peer_id, JSON.stringify(response))
                    else:
                        emit_signal("action", instruction["role"], instruction["item"], instruction["action"])
            else:
                print("Could not parse instruction - not JSON?")
                print(message)
        return message
    return bytes_to_var(pkt)

func send_role_environment(role: String, environment: Array[Dictionary]):
    for key in players:
        if players[key] == role:
            send_environment(key, environment)
            break

#Stub. Split up just for consistency and less likely to break
func send_environment(peer_id: int, environment: Array[Dictionary]):
    #var environment : Array[Dictionary] = get_parent().player_lookup[peer_id]
    var response = {"type":"environment", "response":environment}
    send(peer_id, JSON.stringify(response))

func send_role_result(role: String, type: String, id: int, data: String):
    for key in players:
        if players[key] == role:
            send_result(key, type, id, data)

func send_result(peer_id: int, type: String, id: int, data: String):
    var response = {"type": type, "id": id, "data": data}
    send(peer_id, JSON.stringify(response))

func has_message(peer_id: int) -> bool:
    assert(peers.has(peer_id))
    return peers[peer_id].get_available_packet_count() > 0

func _create_peer() -> WebSocketPeer:
    var ws := WebSocketPeer.new()
    return ws

func send_to_all(message: String):
    send(0, message)
