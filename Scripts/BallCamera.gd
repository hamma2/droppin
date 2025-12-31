extends Camera2D
class_name BallCamera

@export var base_speed: float = 350.0
@export var speed_increase: float = 1.0  # Pixel pro Sekunde Erhöhung
@export var follow_speed: float = 12.0
@export var target_offset_y: float = 120.0

var ball: RigidBody2D
var current_speed: float = 150.0
var elapsed_time: float = 0.0

func _ready():
    ball = get_parent().find_child("Ball")
    current_speed = base_speed
    if ball == null:
        push_error("Ball nicht gefunden!")
    else:
        # Zentriere den Ball horizontal
        ball.global_position.x = global_position.x

func _physics_process(delta):
    if ball == null:
        return

    # Erhöhe die Geschwindigkeit über die Zeit
    elapsed_time += delta
    current_speed = base_speed + (speed_increase * elapsed_time)

    # Scrolle immer mit aktueller Geschwindigkeit nach unten
    global_position.y += current_speed * delta

    var viewport_size = get_viewport_size()
    var viewport_bottom = global_position.y + viewport_size.y / 2.0
    
    # 30% des Viewport Heights vom unteren Rand
    var bottom_follow_range = viewport_size.y * 0.3

    # Folge dem Ball nur wenn:
    # 1. Ball fällt schneller als Camera UND
    # 2. Ball ist in den unteren 30% des Viewports UND
    # 3. Ball bewegt sich nach unten (positive Y Velocity)
    var ball_fall_speed = ball.linear_velocity.y
    var ball_in_bottom_range = ball.global_position.y > (viewport_bottom - bottom_follow_range)
    var ball_moving_down = ball_fall_speed > 0.0

    if ball_fall_speed > current_speed and ball_in_bottom_range and ball_moving_down:
        var desired_y = ball.global_position.y - (viewport_size.y / 2.0) + target_offset_y
        var factor = clamp(follow_speed * delta, 0.0, 1.0)
        # Nur nach unten folgen, nie nach oben
        if desired_y > global_position.y:
            global_position.y = lerp(global_position.y, desired_y, factor)

func get_viewport_center() -> Vector2:
    """Gibt die Mitte des Viewports in globalen Koordinaten zurück"""
    return global_position

func get_viewport_size() -> Vector2:
    """Gibt die Größe des Viewports zurück"""
    return get_viewport_rect().size

