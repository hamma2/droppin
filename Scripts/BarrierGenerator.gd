extends Node2D
class_name BarrierGenerator

@export var gap_width_scale: float = 2.5
@export var barrier_height_scale: float = 0.7
@export var spawn_interval_scale: float = 1.0
@export var min_barriers: int = 10
@export var barrier_spacing_scale: float = 0.3
@export var extra_spawn_probability: float = 0.2

var barrier_pair_scene = preload("res://Scenes/Barrier.tscn")
var extra_item_scene = preload("res://Scenes/Extra.tscn")

# points extra
var extra_50_points = preload("res://StaticData/Extras/Points/50_points.tres")
var extra_2_multiply_points = preload("res://StaticData/Extras/Points/2_multiply_points.tres")
var extra_item_points_script = preload("res://Scripts/Extras/Points/PointsItem.gd")

# change direction extra
var extra_direction_item = preload("res://StaticData/Extras/Direction/change_direction_5_seconds.tres")
var extra_item_direction_script = preload("res://Scripts/Extras/Direction/DirectionItem.gd")

var time_since_last_spawn: float = 0.0
var barrier_pairs: Array = []
var extra_items: Array = []
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

# Extra-System-Variablen
var available_extra_types: Array = []

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

    # Initialisiere verfügbare Extra-Typen
    setup_extra_types()

    # Spawne initiale Barrieren-Paare mit konsistantem Abstand
    for i in range(min_barriers):
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
    update_extra_items()

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

    # Spawne möglicherweise ein Extra-Item mit dieser Barriere
    spawn_extra_randomly(last_spawn_y)

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

func setup_extra_types() -> void:
    """Initialisiert die verfügbaren Extra-Typen"""
    available_extra_types = [
        extra_50_points,
        extra_2_multiply_points,
        extra_direction_item,
        # ExtraData.new("shield", 5.0, Color.CYAN, null, 1.0, 0.25),
        # ExtraData.new("speed_boost", 3.0, Color.YELLOW, null, 1.0, 0.25),
    ]

func spawn_extra_randomly(barrier_y: float) -> void:
    """Spawnt ein zufälliges Extra-Item mit den Barrieren"""
    var viewport_left = viewport_center.x - screen_width / 2
    var viewport_right = viewport_center.x + screen_width / 2

    # Wähle einen zufälligen Extra-Typ
    var extra_data = available_extra_types[randi() % available_extra_types.size()]

    # Entscheide ob dieses Extra spawnt
    if randf() > extra_data.spawn_probability:
        return

    # Spawne das Extra-Item
    var extra = extra_item_scene.instantiate()

    # set the fitting script
    match extra_data.effect_type:
        "points":
            extra.script = extra_item_points_script
        "direction":
            extra.script = extra_item_direction_script

    extra.position = Vector2(
        randf_range(viewport_left + 100, viewport_right - 100),
        barrier_y - 50.0  # Etwas über der Barriere spawnen
    )
    extra.set_extra_data(extra_data)
    extra.set_viewport_bounds(viewport_left, viewport_right)
    extra.collected.connect(_on_extra_collected)
    extra.destroyed.connect(_on_extra_destroyed)

    add_child(extra)
    extra_items.append(extra)

func _on_extra_collected(extra: Node) -> void:
    """Wird aufgerufen wenn ein Extra gesammelt wird"""
    if extra in extra_items:
        extra_items.erase(extra)

func _on_extra_destroyed(extra: Node) -> void:
    """Wird aufgerufen wenn ein Extra zerstört wird (z.B. Decke)"""
    if extra in extra_items:
        extra_items.erase(extra)

func update_extra_items() -> void:
    """Entfernt Extra-Items die zu weit oben sind"""
    var items_to_remove = []
    for item in extra_items:
        if item.position.y < viewport_center.y - screen_size.y:
            item.queue_free()
            items_to_remove.append(item)

    for item in items_to_remove:
        extra_items.erase(item)
