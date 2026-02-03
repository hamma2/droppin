extends Node2D
class_name WallCollider

@export var wall_width: float = 20.0
@export var ceiling_height: float = 20.0
var camera: Camera2D
var left_wall: StaticBody2D
var right_wall: StaticBody2D
var ceiling: StaticBody2D
var screen_size: Vector2

# Berechne die Kamera-Position einmalig
var camera_center
var viewport_width
var viewport_height

func _ready():
    screen_size = get_viewport_rect().size
    camera = get_parent().find_child("Camera2D")

    # Finde oder erstelle die Wände
    left_wall = get_parent().find_child("LeftWall")
    right_wall = get_parent().find_child("RightWall")
    ceiling = get_parent().find_child("Ceiling")

    left_wall.add_to_group("wall")
    right_wall.add_to_group("wall")

    if left_wall == null or right_wall == null:
        push_error("Wände nicht gefunden!")
        return

    # Berechne die Kamera-Position einmalig
    camera_center = camera.get_global_transform().origin
    viewport_width = screen_size.x
    viewport_height = screen_size.y

    # Aktualisiere die RectangleShape2D Größen auf die volle Viewport-Höhe
    var left_collision = left_wall.get_node("CollisionShape2D")
    var right_collision = right_wall.get_node("CollisionShape2D")

    if left_collision != null and left_collision.shape is RectangleShape2D:
        left_collision.shape.size = Vector2(wall_width, viewport_height * 2)

    if right_collision != null and right_collision.shape is RectangleShape2D:
        right_collision.shape.size = Vector2(wall_width, viewport_height * 2)

    # Positioniere linke Wand
    left_wall.position = Vector2(
        camera_center.x - viewport_width / 2 - wall_width / 2,
        camera_center.y
    )

    # Positioniere rechte Wand
    right_wall.position = Vector2(
        camera_center.x + viewport_width / 2 + wall_width / 2,
        camera_center.y
    )

    # Setup Ceiling - positioniere am oberen Viewport-Rand mit voller Breite
    if ceiling != null:
        setup_ceiling()


func setup_ceiling() -> void:
    """Erstellt und positioniert das Ceiling an der Oberseite des Viewports"""
    if ceiling == null:
        return

    # Finde oder erstelle die CollisionShape2D für das Ceiling
    var ceiling_collision = ceiling.find_child("CollisionShape2D")
    if ceiling_collision == null:
        ceiling_collision = CollisionShape2D.new()
        ceiling_collision.name = "CollisionShape2D"
        ceiling.add_child(ceiling_collision)

    # Erstelle oder aktualisiere die Shape
    if not (ceiling_collision.shape is RectangleShape2D):
        ceiling_collision.shape = RectangleShape2D.new()

    # Setze die Größe der CollisionShape auf die Viewport Breite
    var rect_shape = ceiling_collision.shape as RectangleShape2D
    rect_shape.size = Vector2(viewport_width, ceiling_height)

    # Positioniere das Ceiling in lokalen Camera2D-Koordinaten
    # In lokalen Koordinaten der Camera:
    # - Camera-Center ist bei (0, 0)
    # - Viewport-Top ist bei y = -viewport_height / 2
    # - Ceiling sollte mit seiner unteren Kante am Viewport-Top sein
    # - Also Ceiling-Center bei y = -viewport_height / 2 - ceiling_height / 2
    ceiling.position = Vector2(
        0,
        -viewport_height / 2 - ceiling_height *5
    )
