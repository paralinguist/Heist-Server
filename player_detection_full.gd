extends Node2D

var single_collection := preload("res://player_detection.tscn")
var colliding_objects = []
var limit = 275

signal newObjCollision(body: PhysicsBody2D)
var polygonPoints: Array= []

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
    #for i in range(180):
        #var next = single_collection.instantiate()
        #add_child(next)
        #next.rotation_degrees = -45+i/2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    var thisFrameCollisions = []
    if len(polygonPoints) > 3:
        pass
    polygonPoints = [Vector2.ZERO]
    $RayCast2D.target_position.x = limit
    var angle_dist = []
    for i in range(180):
        $RayCast2D.global_scale = Vector2.ONE
        $RayCast2D.rotation_degrees = -45+i*0.5
        $RayCast2D.force_raycast_update()
        var next_point = Vector2.ZERO
        if !$RayCast2D.is_colliding():
            #$RayCast2D.get_child(0).scale.x = 0#limit
            angle_dist.append([$RayCast2D.rotation, limit])
        else:
            if $RayCast2D.get_collider() not in colliding_objects:
                colliding_objects.append($RayCast2D.get_collider())
                if $RayCast2D.get_collider().is_in_group("Player"):
                    emit_signal("newObjCollision", $RayCast2D.get_collider())
            if $RayCast2D.get_collider() not in thisFrameCollisions:
                thisFrameCollisions.append($RayCast2D.get_collider())
            #$RayCast2D.get_child(0).scale.x = 0#$RayCast2D.global_position.distance_to($RayCast2D.get_collision_point()) /self.global_scale.x
            angle_dist.append([$RayCast2D.rotation, $RayCast2D.global_position.distance_to($RayCast2D.get_collision_point()) /self.global_scale.x])
            #next_point = Vector2($RayCast2D.global_position.distance_to($RayCast2D.get_collision_point()) /self.global_scale.x, 0).rotated($RayCast2D.rotation)
    polygonPoints = angle_dist
    if len(polygonPoints) >= 3:
       # print(polygonPoints)
        var outputPoints = [Vector2.ZERO]
        for p in range(len(polygonPoints)-1):
            var nextvec = Vector2(polygonPoints[p][1], 0).rotated(polygonPoints[p][0]+0.174533)
            outputPoints.append(nextvec)
            nextvec = Vector2(polygonPoints[p][1], 0).rotated(polygonPoints[p+1][0]+0.174533)
            outputPoints.append(nextvec)
        #print(outputPoints)
        $Polygon2D.polygon = outputPoints
        #draw_colored_polygon(outputPoints, Color(1.0, 0.0, 0.0, 1.0))
    for c in colliding_objects:
        if c not in thisFrameCollisions:
            colliding_objects.erase(c)
