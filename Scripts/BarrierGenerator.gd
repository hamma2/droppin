extends Node2D
class_name BarrierGenerator

@export var barrier_fall_speed_scale: float = 1.0
@export var gap_width_scale: float = 1.0
@export var barrier_height_scale: float = 1.0
@export var spawn_interval_scale: float = 1.0
@export var min_barriers: int = 5
@export var safety_margin: float = 300.0
@export var barrier_spacing_scale: float = 0.15

var barrier_pair_scene = preload("res://Scenes/Barrier.tscn")
var time_since_last_spawn: float = 0.0
var barrier_pairs: Array = []
var screen_size: Vector2
var barrier_fall_speed: float
var gap_width: float
var barrier_height: float
var screen_width: float
var spawn_interval: float
var min_gap_x: float
var max_gap_x: float
var next_spawn_y: float = 0.0
var ball: Node2D
var base_barrier_speed: float
var camera: Camera2D
var viewport_center: Vector2
var barrier_spacing: float

func _ready():
    screen_size = get_viewport_rect().size
    barrier_fall_speed = (screen_size.y * 1.4) * barrier_fall_speed_scale
    base_barrier_speed = barrier_fall_speed
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
    next_spawn_y = viewport_center.y + screen_size.y + 200.0

    # Spawne initiale Barrieren-Paare
    for i in range(min_barriers):
        spawn_barrier_pair()
        next_spawn_y += barrier_spacing

func _physics_process(delta):
    time_since_last_spawn += delta

    # Dynamische Geschwindigkeitsanpassung
    if ball != null:
        adjust_barrier_speed_to_ball()

    # Spawne neue Barrieren-Paare
    if time_since_last_spawn >= spawn_interval or barrier_pairs.size() < min_barriers:
        spawn_barrier_pair()
        time_since_last_spawn = 0.0

    update_barriers()

func adjust_barrier_speed_to_ball():
    """Passt die Barrieregeschwindigkeit dynamisch an, um den Ball nicht fallen zu lassen"""
    var lowest_barrier_y = -INF
    for pair in barrier_pairs:
        if pair.position.y > lowest_barrier_y:
            lowest_barrier_y = pair.position.y

    var screen_bottom = viewport_center.y + screen_size.y / 2
    var ball_speed = abs(ball.linear_velocity.y)

    barrier_fall_speed = base_barrier_speed + (ball_speed * 0.8)

    var ball_distance_to_bottom = screen_bottom - ball.position.y

    if ball_distance_to_bottom < safety_margin:
        var urgency_factor = 1.0 - (ball_distance_to_bottom / safety_margin)
        barrier_fall_speed += urgency_factor * screen_size.y * 2.0
        print("EMERGENCY SPEED BOOST! Distance: ", ball_distance_to_bottom, " Speed: ", barrier_fall_speed)

    var min_required_speed = ball_speed * 1.2
    barrier_fall_speed = max(barrier_fall_speed, min_required_speed)

    for pair in barrier_pairs:
        pair.velocity.y = -barrier_fall_speed

func spawn_barrier_pair():
    """Spawnt ein neues Barrieren-Paar (links + rechts + gap)"""
    var viewport_left = viewport_center.x - screen_width / 2
    var viewport_right = viewport_center.x + screen_width / 2

    # KORRIGIERT: Gap-Position random zwischen 6% und 94% der Bildschirmbreite
    var gap_center = randf_range(
        viewport_left + min_gap_x,
        viewport_left + max_gap_x
    )

    # Debug-Ausgabe
    print("Gap spawned at X: ", gap_center, " (Range: ", viewport_left + min_gap_x, " - ", viewport_left + max_gap_x, ")")

    var pair = barrier_pair_scene.instantiate()
    pair.position = Vector2(0, next_spawn_y)
    pair.gap_center_x = gap_center
    pair.gap_width = gap_width
    pair.barrier_height = barrier_height
    pair.fall_speed = barrier_fall_speed
    pair.viewport_left = viewport_left
    pair.viewport_right = viewport_right

    add_child(pair)
    barrier_pairs.append(pair)

    next_spawn_y += barrier_spacing

func update_barriers():
    """Entfernt alte Barrieren-Paare"""
    var pairs_to_remove = []
    for pair in barrier_pairs:
        if pair.position.y < viewport_center.y - screen_size.y:
            pair.queue_free()
            pairs_to_remove.append(pair)

    for pair in pairs_to_remove:
        barrier_pairs.erase(pair)

    check_and_spawn_below_ball()

func check_and_spawn_below_ball():
    """Spawnt zusätzliche Barrieren, falls zu wenige unter dem Ball sind"""
    if ball == null:
        return

    var barriers_below_ball = 0
    for pair in barrier_pairs:
        if pair.position.y > ball.position.y:
            barriers_below_ball += 1

    if barriers_below_ball < 3:
        var lowest_y = ball.position.y
        for pair in barrier_pairs:
            if pair.position.y > lowest_y:
                lowest_y = pair.position.y

        next_spawn_y = lowest_y + barrier_spacing
        spawn_barrier_pair()
