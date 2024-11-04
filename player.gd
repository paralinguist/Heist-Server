extends Node2D

const UP: int = 0
const DOWN: int = 1
const LEFT: int = 2
const RIGHT: int = 3

const ACTION_SUCCESS = 0
const ACTION_FAILURE = 1
const ACTION_CANCELLED = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

class player:
    #Attempt to move one grid space in the direction indicated - maybe some roles can move faster?
    func move(direction: int):
        pass
    
    #Attempt to "use" an item from any adjacent tile - usually picking up an objective, freeing a player, opening unlocked doors etc
    func use():
        pass

class lockpick extends player:
    #if a pickable item is adjacent, will return true to indicate the client can try, otherwise false
    #should lock the player in place until finished/canceled
    func attempt_lockpick():
        return true

    #client indicates the lockpick attempt is over
    func finish_lockpick(result: int):
        match result:
            ACTION_SUCCESS:
                #unlock adjacent
                pass
            ACTION_FAILURE:
                #increase heat level
                pass
            ACTION_CANCELLED:
                #free up movement
                pass
        
    func attempt_safecrack():
        return true
