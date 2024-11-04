extends Node2D

#Server listening port
const PORT: int = 9876
@onready var _log_dest: RichTextLabel = $Panel/VBoxContainer/_log_dest
@onready var _server: WebSocketServer = $WebSocketServer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func info(msg: String) -> void:
    print(msg)
    _log_dest.add_text(str(msg) + "\n")

func _on_button_pressed() -> void:
    _server.send_to_all("Message from server")
