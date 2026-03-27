extends Node2D
class_name BallPointsCollector

@export var display_font_size: int = 28
@export var delay_before_animation: float = 0.5

var accumulated_points: int = 0
var time_since_last_point: float = 0.0
var is_animating: bool = false

@onready var label: Label = $Label

var game_manager: GameManager = null
var floating_points_scene = preload("res://Scenes/ui/FloatingPoints.tscn")

func _ready():
    update_label_display()

func add_points(points: int) -> void:
    """Add points to the accumulator and reset the timer"""
    accumulated_points += points
    time_since_last_point = 0.0
    is_animating = false
    update_label_display()
    
    # Make label visible
    label.visible = true

func _process(delta: float) -> void:
    # Only count time if we have points and not animating
    if accumulated_points > 0 and not is_animating:
        time_since_last_point += delta
        
        # Trigger animation after delay
        if time_since_last_point >= delay_before_animation:
            trigger_animation()

func trigger_animation() -> void:
    """Trigger the floating points animation and reset counter"""
    if accumulated_points <= 0:
        return
    
    # Get the root scene (PlayScene)
    var root_scene = get_parent()
    while root_scene.get_parent() != null and root_scene.name != "PlayScene":
        root_scene = root_scene.get_parent()
    
    # Lazy initialization of game_manager
    if game_manager == null:
        game_manager = root_scene.find_child("GameManager")
    
    if game_manager == null:
        return
    
    is_animating = true
    label.visible = false
    
    # Spawn the floating points animation
    var floating_points = floating_points_scene.instantiate()
    root_scene.add_child(floating_points)
    
    # Get target position (score label)
    var score_label = game_manager.score_label
    if score_label == null:
        floating_points.queue_free()
        accumulated_points = 0
        return
    
    # Start position: this collector's position (world space)
    var start_pos = global_position
    var target_pos = score_label.get_global_rect().get_center()
    
    # Convert target from screen space to world space
    if game_manager.camera != null:
        target_pos = game_manager.camera.get_canvas_transform().affine_inverse() * target_pos
    
    floating_points.setup(accumulated_points, start_pos, target_pos)
    
    game_manager.score += accumulated_points

    # Reset after animation
    accumulated_points = 0


func update_label_display() -> void:
    """Update the label to show accumulated points"""
    if accumulated_points <= 0:
        label.text = ""
        label.visible = false
    else:
        label.text = "+" + str(accumulated_points)
        label.visible = true
