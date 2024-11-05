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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if is_test:
        if Input.is_action_just_pressed("down"):
            move(DOWN)
        if Input.is_action_just_pressed("left"):
            move(LEFT)
        if Input.is_action_just_pressed("right"):
            move(RIGHT)
        if Input.is_action_just_pressed("up"):
            move(UP)

#Attempt to move one grid space in the direction indicated - maybe some roles can move faster?
func move(direction: int):
    var old_position := position
    var move_direction := GRID_SIZE * Vector2(1, 0).rotated(direction * TAU/4.0)
    #True if collision, in which case move back. False if move was successful
    if move_and_collide(move_direction, false):
        position = old_position
#Attempt to "use" an item from any adjacent tile - usually picking up an objective, freeing a player, opening unlocked doors etc
func use():
    pass
