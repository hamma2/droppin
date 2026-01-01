extends Node2D
class_name BarrierPair

@export var gap_center_x: float = 400.0
@export var gap_width: float = 100.0
@export var barrier_height: float = 20.0

var left_barrier: StaticBody2D
var right_barrier: StaticBody2D
var viewport_left: float
var viewport_right: float

func _ready():
    setup_barriers()

func setup_barriers():
    """Erstellt die linke und rechte statische Barriere mit Loch in der Mitte"""
    # Linke Barriere: von viewport_left bis gap start
    left_barrier = create_barrier("LeftBarrier")
    var left_width = gap_center_x - gap_width / 2 - viewport_left
    left_barrier.position = Vector2(viewport_left + left_width / 2, 0)
    setup_barrier_shape(left_barrier, left_width)
    add_child(left_barrier)

    # Rechte Barriere: von gap end bis viewport_right (mit kleinem Puffer für Vollständigkeit)
    right_barrier = create_barrier("RightBarrier")
    var gap_end = gap_center_x + gap_width / 2
    var right_width = viewport_right - gap_end + 100.0  # TODO: make dymanic based on resulution +100 pixel buffer für lückenlose Abdeckung
    right_barrier.position = Vector2(gap_end + right_width / 2, 0)
    setup_barrier_shape(right_barrier, right_width)
    add_child(right_barrier)

func create_barrier(barrier_name: String) -> StaticBody2D:
    """Erstellt eine einzelne statische Barriere"""
    var barrier = StaticBody2D.new()
    barrier.name = barrier_name
    return barrier

func setup_barrier_shape(barrier: StaticBody2D, width: float):
    """Setzt CollisionShape und ColorRect für eine Barriere"""
    # CollisionShape2D
    var collision = CollisionShape2D.new()
    var shape = RectangleShape2D.new()
    shape.extents = Vector2(width / 2.0, barrier_height / 2.0)
    collision.shape = shape
    collision.position = Vector2(0, 0)
    barrier.add_child(collision)

    # ColorRect für Visualisierung
    # var color_rect = ColorRect.new()
    # color_rect.position = Vector2(-width / 2-5, -barrier_height / 2-5)
    # color_rect.size = Vector2(width+10, barrier_height+10)
    # color_rect.color = Color(240, 67, 127, 255) /255 
    # barrier.add_child(color_rect)

    # Add Sprite for visual representation (optional)
    var sprite = Sprite2D.new()
    var texture = preload("res://Textures/sky_postcard_theme/grass_barrier.svg")
    sprite.texture = texture
    sprite.scale = Vector2(width / texture.get_width(), barrier_height / texture.get_height())
    sprite.position = Vector2(0, 0)
    #sprite.self_modulate = Color(242, 214, 162, 255) /255  # Orange Farbe
    barrier.add_child(sprite)
