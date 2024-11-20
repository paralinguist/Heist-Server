extends charmable

var next_rot := true
const GRID_SIZE := 32

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    super()
    item_type = "guard"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
    
func move(direction: int):
    var old_position := position
    var move_direction := GRID_SIZE * Vector2(1, 0).rotated(direction * TAU/4.0)
    #True if collision, in which case move back. False if move was successful
    if self.move_and_collide(move_direction, false):
        position = old_position

func _on_timer_timeout() -> void:
    if next_rot:
        rotation = randi()%4 * TAU/4
    else:
        move(round(rotation/(TAU/4)))
    next_rot = not next_rot

func get_actions():
    return ["charm", "distract", "earpiece"]
