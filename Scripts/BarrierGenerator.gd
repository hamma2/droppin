extends Node2D
class_name BarrierGenerator

@export var gap_width_scale: float = 1.0
@export var barrier_height_scale: float = 1.0
@export var spawn_interval_scale: float = 1.0
@export var min_barriers: int = 5
@export var barrier_spacing_scale: float = 0.15

var barrier_pair_scene = preload("res://Scenes/Barrier.tscn")
var time_since_last_spawn: float = 0.0
var barrier_pairs: Array = []
var screen_size: Vector2
var gap_width: float
var barrier_height: float
var screen_width: float
var spawn_interval: float
var min_gap_x: float
var max_gap_x: float
var last_spawn_y: float = 0.0
var ball: Node2D
var camera: Camera2D
var viewport_center: Vector2
var barrier_spacing: float

func _ready():
    screen_size = get_viewport_rect().size
    gap_width = screen_size.x * 0.12 * gap_width_scale
    barrier_height = screen_size.y * 0.03 * barrier_height_scale
    screen_width = screen_size.x
    spawn_interval = 2.0 * spawn_interval_scale
    min_gap_x = screen_size.x * 0.06
    max_gap_x = screen_size.x * 0.94
    barrier_spacing = screen_size.y * barrier_spacing_scale

    ball = get_parent().find_child("Ball")
    camera = get_parent().find_child("Camera2D")

    if ball == null:
        push_error("Ball nicht gefunden!")
    if camera == null:
        push_error("Camera nicht gefunden!")

    viewport_center = camera.get_viewport_center() if camera else Vector2.ZERO
    # Initialize last_spawn_y so first barrier spawns at a consistent position
    last_spawn_y = viewport_center.y + screen_size.y

    # Spawne initiale Barrieren-Paare mit konsistantem Abstand
    for i in range(min_barriers):
        last_spawn_y += barrier_spacing
        spawn_barrier_pair()

func _physics_process(delta):
    time_since_last_spawn += delta

    # Aktualisiere Kamera-Mittpunkt
    viewport_center = camera.get_viewport_center() if camera else viewport_center

    # Spawne neue Barrieren-Paare unterhalb der Kamera
    if time_since_last_spawn >= spawn_interval or count_barriers_below_camera() < min_barriers:
        spawn_barrier_pair()
        time_since_last_spawn = 0.0

    update_barriers()

func spawn_barrier_pair():
    """Spawnt ein neues statisches Barrieren-Paar unterhalb der Kamera"""
    var viewport_left = viewport_center.x - screen_width / 2
    var viewport_right = viewport_center.x + screen_width / 2

    # Gap-Position random zwischen 6% und 94% der Bildschirmbreite
    var gap_center = randf_range(
        viewport_left + min_gap_x,
        viewport_left + max_gap_x
    )

    var pair = barrier_pair_scene.instantiate()
    # Positioniere Paar bei (0, last_spawn_y) - gap_center wird relativ berechnet
    pair.position = Vector2(0, last_spawn_y)
    pair.gap_center_x = gap_center
    pair.gap_width = gap_width
    pair.barrier_height = barrier_height
    pair.viewport_left = viewport_left
    pair.viewport_right = viewport_right

    add_child(pair)
    barrier_pairs.append(pair)

    last_spawn_y += barrier_spacing

func update_barriers():
    """Entfernt alte Barrieren-Paare, die oberhalb des sichtbaren Bereichs sind"""
    var pairs_to_remove = []
    for pair in barrier_pairs:
        if pair.position.y < viewport_center.y - screen_size.y:
            pair.queue_free()
            pairs_to_remove.append(pair)

    for pair in pairs_to_remove:
        barrier_pairs.erase(pair)

func count_barriers_below_camera() -> int:
    """Zählt die Barrieren unterhalb der Kamera"""
    var count = 0
    for pair in barrier_pairs:
        if pair.position.y > viewport_center.y:
            count += 1
    return count
