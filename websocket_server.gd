class_name WebSocketServer
extends Node

const UP: int = 3
const DOWN: int = 1
const LEFT: int = 2
const RIGHT: int = 0

var api_version = "1.01"

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
    for i in range(12):
        print(get_lock_info())
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
                    #Calling the function to reply to move requests directly - ultimately this should be removed
                elif instruction["action"] in ["hack", "pick", "change", "read"]:
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

func generate_serial():
    var characters = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    var digits = ["0","1","2","3","4","5","6","7","8"]
    var separators = ["-","/"]
    var prefix = ""
    var middle = ""
    var suffix = ""
    for i in range(randi()%4+1):
        prefix += characters.pick_random()
    for i in range(randi()%5+3):
        middle += digits.pick_random()
    var suffix_type = randi()%2
    for i in range(randi()%3+1):
        if suffix_type == 1:
            suffix += characters.pick_random()
        else:
            suffix += digits.pick_random()
    var separator = separators.pick_random()
    return prefix + separator + middle + separator + suffix
    
func get_brands(number = 1):
    var brands = ["FortiVault", "CryptKeep", "Bolt & Key", "ProtecSure", "Ironclad Safe Co.", "Omega Locks", "PermaSecure", "TruGuard Systems", "IrnGrd Inc"]
    brands.shuffle()
    var selection = []
    for i in range(number):
        selection.append(brands.pop_back())
    return selection
    
func get_lock_info():
    var serial = generate_serial()
    var brands = get_brands(4)
    return {"serial":serial, "brand":brands[0], "fake1":brands[1], "fake2":brands[2], "fake3":brands[3]}
