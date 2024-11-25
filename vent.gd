extends usable


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    super()
    pass # Replace with function body.

func use(player: String, action: String):
    super(player, action)
    #Check for lockpick
    #Change icon to open vent
    $CollisionShape2D.disabled = true
    
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
