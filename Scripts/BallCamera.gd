extends Camera2D
class_name BallCamera

@export var follow_speed: float = 5.0
@export var target_offset_y: float = 100.0
var ball: Node2D
var initial_position: Vector2
var viewport_center: Vector2

func _ready():
    ball = get_parent().find_child("Ball")
    initial_position = global_position
    viewport_center = get_viewport_rect().size / 2
    if ball == null:
        push_error("Ball nicht gefunden!")

func _physics_process(_delta):
    if ball == null:
        return
    
    # Kamera bleibt an der Startposition (scrollt nicht mit dem Ball)
    global_position = initial_position

func get_viewport_center() -> Vector2:
    """Gibt die Mitte des Viewports in globalen Koordinaten zurück"""
    return global_position

func get_viewport_size() -> Vector2:
    """Gibt die Größe des Viewports zurück"""
    return get_viewport_rect().size

