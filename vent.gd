extends usable


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    super()
    pass # Replace with function body.
    use("hi", "use")

func use(player: String, action: String):
    super(player, action)
    #Check for lockpick
    #Change icon to open vent
    print("using vent")
    $CollisionShape2D.disabled = true
    $Sprite2D2.modulate = Color(0.1, 0.1, 0.1, 1.0)
    
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
