extends StaticBody2D

var closed := true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func toggle_state():
    if closed:
        closed = false
        $Sprite2D.play("Open")
        $CollisionShape2D.disabled = true
    else:
        closed = true
        $Sprite2D.play("Closed")
        $CollisionShape2D.disabled = false
