extends usable

var open = false

var VentStream : AudioStream = preload("res://assets/Sounds/vent_open.wav")
var VentSound = AudioStreamPlayer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    super()
    VentSound.stream = VentStream
    add_child(VentSound)

func use(player: String, action: String):
    super(player, action)
    #Check for lockpick
    #Change icon to open vent
    open = true
    $CollisionShape2D.disabled = true
    $Sprite2D2.modulate = Color(0.1, 0.1, 0.1, 1.0)
    VentSound.play()
    
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func get_actions() -> Array[String]:
    if not open:
        return ["use"]
    else:
        return []
