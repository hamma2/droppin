extends Camera2D
class_name BallCamera

@export var base_speed: float = 150.0
@export var follow_speed: float = 12.0
@export var target_offset_y: float = 120.0
@export var bottom_margin: float = 220.0

var ball: RigidBody2D

func _ready():
    ball = get_parent().find_child("Ball")
    if ball == null:
        push_error("Ball nicht gefunden!")
    else:
        # Zentriere den Ball horizontal
        ball.global_position.x = global_position.x

func _physics_process(delta):
    if ball == null:
        return

    # Scrolle immer mit base_speed nach unten
    global_position.y += base_speed * delta

    var viewport_size = get_viewport_size()
    var viewport_bottom = global_position.y + viewport_size.y / 2.0

    # Wenn Ball schneller fällt oder nahe der Unterkante ist, folge dem Ball
    var ball_fall_speed = ball.linear_velocity.y
    var ball_near_bottom = ball.global_position.y > (viewport_bottom - bottom_margin)

    if ball_fall_speed > base_speed or ball_near_bottom:
        var desired_y = ball.global_position.y - (viewport_size.y / 2.0) + target_offset_y
        var factor_mult = 1.0
        if ball_near_bottom:
            factor_mult = 3.0
        var factor = clamp(follow_speed * delta * factor_mult, 0.0, 1.0)
        global_position.y = lerp(global_position.y, desired_y, factor)
        # Snap wenn Ball deutlich unterhalb
        if ball.global_position.y > (viewport_bottom + 100.0):
            global_position.y = desired_y

func get_viewport_center() -> Vector2:
    """Gibt die Mitte des Viewports in globalen Koordinaten zurück"""
    return global_position

func get_viewport_size() -> Vector2:
    """Gibt die Größe des Viewports zurück"""
    return get_viewport_rect().size

