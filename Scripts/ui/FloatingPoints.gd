extends Node2D
class_name FloatingPoints

@export var flight_duration: float = 0.6
@export var fade_duration: float = 0.4
@export var use_curve: bool = true

var points: int = 0
var start_position: Vector2
var target_position: Vector2
var elapsed_time: float = 0.0
var is_animating: bool = false

@onready var label: Label = $Label

# Animation curve for smoother movement
var animation_curve: Curve = Curve.new()

func _ready():
    # Setup animation curve for easing
    animation_curve.add_point(Vector2(0, 0))
    animation_curve.add_point(Vector2(0.5, 1.2))  # Overshoot in middle
    animation_curve.add_point(Vector2(1, 1))

    start_animation()

func setup(initial_points: int, from_position: Vector2, to_position: Vector2) -> void:
    """Initialize the floating points with start and end positions"""
    points = initial_points
    start_position = from_position
    target_position = to_position
    global_position = from_position
    
    label.text = "+" + str(points)
    
func start_animation() -> void:
    """Start the animation sequence"""
    is_animating = true
    elapsed_time = 0.0
    
    # Add random horizontal drift for visual variety
    var drift = randf_range(-30, 30)
    target_position.x += drift

func _process(delta: float) -> void:
    if not is_animating:
        return
    
    elapsed_time += delta
    
    if elapsed_time >= flight_duration + fade_duration:
        queue_free()
        return
    
    # Flight phase (0 to flight_duration)
    if elapsed_time <= flight_duration:
        var progress = elapsed_time / flight_duration
        var eased_progress = animation_curve.sample(progress) if use_curve else progress
        
        # Interpolate position
        global_position = start_position.lerp(target_position, eased_progress)
        
        # Move upward during flight (arc motion)
        var arc_height = sin(progress * PI) * 50
        global_position.y -= arc_height
    else:
        # Fade phase (after flight_duration)
        var fade_progress = (elapsed_time - flight_duration) / fade_duration
        var fade_alpha = 1.0 - fade_progress
        label.modulate.a = fade_alpha
        
        # Slight upward movement during fade
        global_position.y -= 10 * get_physics_process_delta_time()
