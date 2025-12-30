extends Node2D
class_name BarrierPair

@export var gap_center_x: float = 400.0
@export var gap_width: float = 100.0
@export var barrier_height: float = 20.0
@export var fall_speed: float = 200.0
@export var bounce: float = 10 # NEU: Bounce-Stärke (0.0 = kein bounce, 1.0 = perfekter bounce)

var left_barrier: RigidBody2D  # GEÄNDERT zu RigidBody2D
var right_barrier: RigidBody2D
var velocity: Vector2 = Vector2.ZERO
var viewport_left: float
var viewport_right: float

func _ready():
    velocity.y = -fall_speed
    setup_barriers()

func setup_barriers():
    """Erstellt die linke und rechte Barriere"""
    # Linke Barriere
    left_barrier = create_barrier("LeftBarrier")
    var left_width = gap_center_x - gap_width / 2 - viewport_left
    left_barrier.position.x = viewport_left + left_width / 2
    setup_barrier_shape(left_barrier, left_width)
    add_child(left_barrier)

    # Rechte Barriere
    right_barrier = create_barrier("RightBarrier")
    var right_width = viewport_right - (gap_center_x + gap_width / 2)
    right_barrier.position.x = gap_center_x + gap_width / 2 + right_width / 2
    setup_barrier_shape(right_barrier, right_width)
    add_child(right_barrier)

func create_barrier(barrier_name: String) -> RigidBody2D:
    """Erstellt eine einzelne Barriere mit RigidBody2D"""
    var barrier = RigidBody2D.new()
    barrier.name = barrier_name

    # PhysicsMaterial für Bounce
    var physics_material = PhysicsMaterial.new()
    physics_material.bounce = bounce
    physics_material.friction = 0.1
    barrier.physics_material_override = physics_material

    # WICHTIG: Freeze RigidBody2D
    barrier.freeze = true  # Verhindert Physics-Bewegung
    barrier.gravity_scale = 0.0
    barrier.lock_rotation = true

    return barrier

func setup_barrier_shape(barrier: RigidBody2D, width: float):
    """Setzt CollisionShape und ColorRect für eine Barriere"""
    # CollisionShape2D
    var collision = CollisionShape2D.new()
    var shape = RectangleShape2D.new()
    shape.size = Vector2(width, barrier_height)
    collision.shape = shape
    barrier.add_child(collision)

    # ColorRect für Visualisierung
    var color_rect = ColorRect.new()
    color_rect.position = Vector2(-width / 2, -barrier_height / 2)
    color_rect.size = Vector2(width, barrier_height)
    color_rect.color = Color.WHITE
    barrier.add_child(color_rect)

func _physics_process(delta):
    """Bewegt das gesamte Barrier-Paar"""
    position += velocity * delta

func set_velocity(new_velocity: Vector2):
    """Setzt die Geschwindigkeit für beide Barrieren gleichzeitig"""
    velocity = new_velocity
