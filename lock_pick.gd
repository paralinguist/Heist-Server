extends "res://player.gd"

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
