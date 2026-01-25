extends Node2D
class_name BarrierPair

@export var gap_center_x: float = 400.0
@export var gap_width: float = 100.0
@export var barrier_height: float = 50.0

var left_barrier: StaticBody2D
var right_barrier: StaticBody2D
var viewport_left: float
var viewport_right: float

func _ready():
    setup_barriers()

func setup_barriers():
    """Erstellt die linke und rechte statische Barriere mit Loch in der Mitte"""
    # Linke Barriere: von viewport_left bis gap start
    var barrierName: String = "LeftBarrier"
    left_barrier = create_barrier(barrierName)
    var left_width: float = gap_center_x - gap_width / 2 - viewport_left
    left_barrier.position = Vector2(viewport_left + left_width / 2, 0)
    setup_barrier_shape(left_barrier, left_width, barrierName)
    add_child(left_barrier)

    # Rechte Barriere: von gap end bis viewport_right (mit kleinem Puffer für Vollständigkeit)
    barrierName = "RightBarrier"
    right_barrier = create_barrier(barrierName)
    var gap_end: float = gap_center_x + gap_width / 2
    var right_width: float = viewport_right - gap_end + 100.0  # dymanic based on resulution +100 pixel buffer für lückenlose Abdeckung
    right_barrier.position = Vector2(gap_end + right_width / 2, 0)
    setup_barrier_shape(right_barrier, right_width, barrierName)
    add_child(right_barrier)

func create_barrier(barrier_name: String) -> StaticBody2D:
    """Erstellt eine einzelne statische Barriere"""
    var barrier = StaticBody2D.new()
    barrier.name = barrier_name
    return barrier

func setup_barrier_shape(barrier: StaticBody2D, width: float, _barrierName: String):
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

    var panelContainer = PanelContainer.new()
    panelContainer.position = Vector2(-width/2, -barrier_height/2)
    panelContainer.size = Vector2(width, barrier_height)
    panelContainer.clip_children = true
    var boxFlatRounderCorners = StyleBoxFlat.new()
    # depending on the barrier side, round different corners
    if(_barrierName=="LeftBarrier"):
        boxFlatRounderCorners.corner_radius_top_right = 15.0
        boxFlatRounderCorners.corner_radius_bottom_right = 15.0
    else:
        boxFlatRounderCorners.corner_radius_top_left = 15.0
        boxFlatRounderCorners.corner_radius_bottom_left = 15.0
    panelContainer.add_theme_stylebox_override("panel",boxFlatRounderCorners)
    barrier.add_child(panelContainer)

    # Add Sprite for visual representation
    var textRect = TextureRect.new()
    var texture = preload("res://Textures/sky_postcard_theme/large_grass.png")
    textRect.texture = texture
    textRect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    textRect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    #textRect.position = Vector2(-width/2, -barrier_height/2)
    #textRect.size = Vector2(width, barrier_height)
    #textRect.material = ShaderMaterial.new()
    #textRect.material.shader = preload("res://Shaders/round_corner_shader.gdshader")
    panelContainer.add_child(textRect)

    #var sprite = Sprite2D.new()
    #var texture = preload("res://Textures/sky_postcard_theme/grass_barrier.svg")
    #sprite.texture = texture
    #sprite.scale = Vector2(width / texture.get_width(), barrier_height / texture.get_height())
    #sprite.position = Vector2(0, 0)
    ##sprite.self_modulate = Color(242, 214, 162, 255) /255  # Orange Farbe
    #barrier.add_child(sprite)
