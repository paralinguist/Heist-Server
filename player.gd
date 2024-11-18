extends CharacterBody2D

const UP: int = 3
const DOWN: int = 1
const LEFT: int = 2
const RIGHT: int = 0

const ACTION_SUCCESS := 0
const ACTION_FAILURE := 1
const ACTION_CANCELLED := 2

const GRID_SIZE := 32

@export var is_test := false
@export var p_name := "lockpick"
var role := ""
var movelock := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

func process_move(nam: String, dir: int):
    if nam == p_name and not movelock:
        move(dir)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if role:
        $Sprite2D.play(role.to_lower())
    if is_test:
        if Input.is_action_just_pressed("down"):
            move(DOWN)
        if Input.is_action_just_pressed("left"):
            move(LEFT)
        if Input.is_action_just_pressed("right"):
            move(RIGHT)
        if Input.is_action_just_pressed("up"):
            move(UP)
        if Input.is_action_just_pressed("use"):
            use()

#Attempt to move one grid space in the direction indicated - maybe some roles can move faster?
func move(direction: int):
    var old_position := position
    var move_direction := GRID_SIZE * Vector2(1, 0).rotated(direction * TAU/4.0)
    #True if collision, in which case move back. False if move was successful
    if move_and_collide(move_direction, false):
        position = old_position
#Attempt to "use" an item from any adjacent tile - usually picking up an objective, freeing a player, opening unlocked doors etc
func use():
    for i in range(8):
        $PlayerBase/ActionChecker.rotation = TAU/8*i
        $PlayerBase/ActionChecker.force_raycast_update()
        if $PlayerBase/ActionChecker.is_colliding():
            var new_col : Object = $PlayerBase/ActionChecker.get_collider()
            if new_col.is_in_group("Door"):
                new_col.get_parent().toggle_state()

func get_local_env() -> Array[Dictionary]:
    var env_objects : Array[Dictionary]= []
    for i in range(8):
        var dir_object := {"direction": Global.dir_lookup[i], "type": "none", "id":"", "actions":[]}
        $PlayerBase/ActionChecker.rotation = TAU/8*i
        $PlayerBase/ActionChecker.force_raycast_update()
        if $PlayerBase/ActionChecker.is_colliding():
            var new_col : Object = $PlayerBase/ActionChecker.get_collider()
            if new_col.get_parent().is_in_group("Tiles"):
                new_col = new_col.get_parent()
            if "id" in new_col:
                dir_object["id"] = str(new_col.id)
            if new_col.is_in_group("Door"):
                dir_object["type"] = "door"
                dir_object["actions"] = new_col.get_actions()
            elif new_col.is_in_group("Safe"):
                dir_object["type"] = "safe"
                dir_object["actions"] = new_col.get_actions()
            elif new_col.is_in_group("Camera"):
                dir_object["type"] = "safe"
                dir_object["actions"] = new_col.get_actions()
            elif new_col.is_in_group("Player"):
                dir_object["type"] = "player"
            elif new_col.is_in_group("Guard"):
                dir_object["type"] = "guard"
                dir_object["actions"] = new_col.get_actions()
            else:
                dir_object["type"] = "wall"
        env_objects.append(dir_object)
    return env_objects

func dont_be_inside():
    while true:
        $InsideDetector.force_raycast_update()
        if not $InsideDetector.is_colliding():
            break
        print("was inside")
        position += GRID_SIZE * Vector2(1, 0).rotated(randi()%4 * TAU/4.0)
