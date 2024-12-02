extends charmable

var next_rot := true
const GRID_SIZE := 32

var starting_tile : Vector2i
var ending_tile : Vector2i
var going_to_end := true
var trapped := []
var distracted := false

func position_to_tile(pos: Vector2) -> Vector2i:
    pos.x -= GRID_SIZE/2
    pos.y -= GRID_SIZE/2
    var tile_pos := Vector2i.ZERO
    tile_pos.x = roundi(pos.x/GRID_SIZE + 0.001)
    tile_pos.y = roundi(pos.y/GRID_SIZE + 0.001)
    return tile_pos
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    super()
    item_type = "guard"
    await get_tree().process_frame
    starting_tile = position_to_tile(global_position)
    ending_tile = position_to_tile($Goal.global_position)
    $Goal.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    for p in trapped:
        p.global_position = global_position
    if Input.is_action_just_pressed("distract"):
        $DistractTimer.start()
        untrap_players()

func use(player: String, action: String):
    if action == "distract" and player == "charmer":
        $DistractTimer.start()
        untrap_players()
            

func move(direction: int):
    var old_position := position
    var move_direction := GRID_SIZE * Vector2(1, 0).rotated(direction * TAU/4.0)
    #True if collision, in which case move back. False if move was successful
    if self.move_and_collide(move_direction, false):
        position = old_position
    if position_to_tile(global_position) == ending_tile:
        going_to_end = false
    elif position_to_tile(global_position) == starting_tile:
        going_to_end = true

func is_direction_free(direction: int) -> bool:
    #True if collision, in which case move back. False if move was successful
    var move_direction := GRID_SIZE * Vector2(1, 0).rotated(direction * TAU/4.0)
    return self.move_and_collide(move_direction, true) == null
func _on_timer_timeout() -> void:
    if next_rot:
        var possible_rotations := []
        for d in range(4):
            if is_direction_free(d):
                possible_rotations.append(d)
        var ideal_collisions = []
        var goal_direction := Vector2i.ZERO
        var current_tile := position_to_tile(global_position)
        if going_to_end:
            goal_direction = ending_tile-current_tile
        else:
            goal_direction = starting_tile-current_tile
        if goal_direction.x != 0:
            var target_dir = -1*(goal_direction.x/abs(goal_direction.x)-1)
            if target_dir in possible_rotations:
                ideal_collisions.append(target_dir)
        if goal_direction.y != 0:
            var target_dir = (goal_direction.y/abs(goal_direction.y))*-1+2
            if target_dir in possible_rotations:
                ideal_collisions.append(target_dir)
        var go_direction = randi()%4
        if len(ideal_collisions) > 0:
            go_direction = ideal_collisions.pick_random()
        elif len(possible_rotations) > 0:
            go_direction = possible_rotations.pick_random()
            going_to_end = !going_to_end
        
        rotation = go_direction * TAU/4
    else:
        move(round(rotation/(TAU/4)))
    next_rot = not next_rot

func get_actions():
    return ["charm", "distract", "earpiece"]

func untrap_players():
    trapped = []
    $PlayerCapture.visible = false
    $PlayerCapture.limit = 0
    distracted = true

func enable_trapping():
    $PlayerCapture.visible = true
    $PlayerCapture.limit = 275
    distracted = false
    

func _on_player_capture_body_entered(body: PhysicsBody2D) -> void:
    if not distracted:
        if body.role != "charmer":
            if body not in trapped:
                trapped.append(body)
                get_tree().current_scene.heat += 10


func _on_distract_timer_timeout() -> void:
    enable_trapping()
