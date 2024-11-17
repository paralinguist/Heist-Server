extends Node

var next_id := 1
const dir_lookup = [
    "south",
    "south_west",
    "west",
    "north_west",
    "north",
    "north_east",
    "east",
    "south_east",
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func generate_serial():
    var characters = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    var digits = ["0","1","2","3","4","5","6","7","8"]
    var separators = ["-","/"]
    var prefix = ""
    var middle = ""
    var suffix = ""
    for i in range(randi()%4+1):
        prefix += characters.pick_random()
    for i in range(randi()%5+3):
        middle += digits.pick_random()
    var suffix_type = randi()%2
    for i in range(randi()%3+1):
        if suffix_type == 1:
            suffix += characters.pick_random()
        else:
            suffix += digits.pick_random()
    var separator = separators.pick_random()
    return prefix + separator + middle + separator + suffix
    
func get_brands(number = 1):
    var brands = ["FortiVault", "CryptKeep", "Bolt & Key", "ProtecSure", "Ironclad Safe Co.", "Omega Locks", "PermaSecure", "TruGuard Systems", "IrnGrd Inc"]
    brands.shuffle()
    var selection = []
    for i in range(number):
        selection.append(brands.pop_back())
    return selection
    
func get_lock_info():
    var serial = generate_serial()
    var brands = get_brands(4)
    return {"serial":serial, "brand":brands[0], "fake1":brands[1], "fake2":brands[2], "fake3":brands[3]}
