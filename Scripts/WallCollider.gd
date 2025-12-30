extends Node2D
class_name WallCollider

@export var wall_width: float = 20.0
var camera: Camera2D
var left_wall: StaticBody2D
var right_wall: StaticBody2D
var screen_size: Vector2

func _ready():
    screen_size = get_viewport_rect().size
    camera = get_parent().find_child("Camera2D")
    
    # Finde oder erstelle die Wände
    left_wall = get_parent().find_child("LeftWall")
    right_wall = get_parent().find_child("RightWall")
    
    if left_wall == null or right_wall == null:
        push_error("Wände nicht gefunden!")
        return
    
    # Berechne die Kamera-Position einmalig
    var camera_center = camera.get_global_transform().origin
    var viewport_width = screen_size.x
    var viewport_height = screen_size.y
    
    # Aktualisiere die RectangleShape2D Größen auf die volle Viewport-Höhe
    var left_collision = left_wall.get_node("CollisionShape2D")
    var right_collision = right_wall.get_node("CollisionShape2D")
    
    if left_collision != null and left_collision.shape is RectangleShape2D:
        left_collision.shape.size = Vector2(wall_width, viewport_height * 2)
    
    if right_collision != null and right_collision.shape is RectangleShape2D:
        right_collision.shape.size = Vector2(wall_width, viewport_height * 2)
    
    # Positioniere linke Wand
    left_wall.position = Vector2(
        camera_center.x - viewport_width / 2 - wall_width / 2,
        camera_center.y
    )
    
    # Positioniere rechte Wand
    right_wall.position = Vector2(
        camera_center.x + viewport_width / 2 + wall_width / 2,
        camera_center.y
    )

