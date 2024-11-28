extends usable

var open = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    super()
    pass # Replace with function body.

func use(player: String, action: String):
    super(player, action)
    #Check for lockpick
    #Change icon to open vent
    open = true
    $CollisionShape2D.disabled = true
    $Sprite2D2.modulate = Color(0.1, 0.1, 0.1, 1.0)
    
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func get_actions() -> Array[String]:
    if not open:
        return ["use"]
    else:
        return []
