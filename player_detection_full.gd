extends Node2D

var single_collection := preload("res://player_detection.tscn")
var colliding_objects = []
var limit = 275

signal newObjCollision(body: PhysicsBody2D)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    for i in range(180):
        var next = single_collection.instantiate()
        add_child(next)
        next.rotation_degrees = -45+i/2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    var thisFrameCollisions = []
    for c in get_children():
        c = c as RayCast2D
        c.target_position.x = limit
        c.force_raycast_update()
        if !c.is_colliding():
            c.get_child(0).scale.x = limit
        else:
            if c.get_collider() not in colliding_objects:
                colliding_objects.append(c.get_collider())
                if c.get_collider().is_in_group("Player"):
                    emit_signal("newObjCollision", c.get_collider())
            if c.get_collider() not in thisFrameCollisions:
                thisFrameCollisions.append(c.get_collider())
            c.get_child(0).scale.x = c.global_position.distance_to(c.get_collision_point()) /self.global_scale.x
    for c in colliding_objects:
        if c not in thisFrameCollisions:
            colliding_objects.erase(c)
