extends usable

var used = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    super()
    item_type = "computer"

func get_actions() -> Array[String]:
    if not used:
        return ["use"]
    else:
        return []
