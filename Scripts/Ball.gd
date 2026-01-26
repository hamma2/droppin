extends RigidBody2D
class_name Ball

signal hit_ceiling

# Physics
@export var bounce: float = 0.56
@export var friction: float = 0.3

@export var gravity_scale_factor: float = 5.0

# Steuerung
@export var keyboard_force: float = 1000.0
@export var accelerometer_sensitivity: float = 300.0
@export var touch_follow_speed: float = 2000.0  # Geschwindigkeit zum Touch-Punkt
@export var max_horizontal_velocity: float = 2800.0

# Input Methoden
@export_enum("Keyboard", "Accelerometer", "Touch", "All") var input_method: int = 3

@onready var sprite = $/root/PlayScene/Ball/CollisionShape2D/Sprite2D

var touch_target_x: float = 0.0
var is_touching: bool = false

# for direction chaging extra
var direction: int = 1

func _ready():
    contact_monitor = true
    max_contacts_reported = 10

    # PhysicsMaterial für Bounce
    var physics_material = PhysicsMaterial.new()
    physics_material.bounce = bounce
    physics_material.friction = friction
    physics_material_override = physics_material

    continuous_cd = CCD_MODE_CAST_RAY
    gravity_scale = gravity_scale_factor
    linear_damp = 0.0
    angular_damp = 0.5

    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node):
    if body.name == "Ceiling" or body.is_in_group("ceiling"):
        emit_signal("hit_ceiling")

func _input(event):
    """Behandelt Touch-Input"""
    if event is InputEventScreenTouch:
        if event.pressed:
            is_touching = true
            touch_target_x = event.position.x
        else:
            is_touching = false

    elif event is InputEventScreenDrag:
        is_touching = true
        touch_target_x = event.position.x

func _physics_process(_delta):
    handle_movement()

    # Begrenze horizontale Geschwindigkeit
    if abs(linear_velocity.x) > max_horizontal_velocity:
        linear_velocity.x = sign(linear_velocity.x) * max_horizontal_velocity
    
    var speed = linear_velocity.length()
    var deform = clamp(speed / 1000.0, 0.0, 0.2)
    sprite.material.set_shader_parameter("deformation_amount", deform)

func handle_movement():
    """Behandelt alle Input-Methoden"""
    var input_force = 0.0

    # Keyboard (Input-Methode 0 oder 3)
    if input_method == 0 or input_method == 3:
        if Input.is_action_pressed("ui_left"):
            input_force -= keyboard_force * direction
        if Input.is_action_pressed("ui_right"):
            input_force += keyboard_force * direction

    # Accelerometer (Input-Methode 1 oder 3)
    if (input_method == 1 or input_method == 3) and Input.get_accelerometer() != Vector3.ZERO:
        var accel = Input.get_accelerometer()
        input_force += accel.x * accelerometer_sensitivity * direction

    # Touch (Input-Methode 2 oder 3)
    if (input_method == 2 or input_method == 3) and is_touching:
        var p_direction = touch_target_x - global_position.x
        input_force += sign(p_direction) * touch_follow_speed * direction

    # Wende Kraft an
    if input_force != 0:
        apply_central_force(Vector2(input_force, 0))

func reset_position(new_position: Vector2):
    position = new_position
    linear_velocity = Vector2.ZERO
    angular_velocity = 0.0
    is_touching = false
