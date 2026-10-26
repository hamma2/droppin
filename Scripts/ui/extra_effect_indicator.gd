extends Control

signal finished

@export var ring_width: float = 4.0
@export var warning_duration: float = 1.5
@export var blink_rate: float = 3.0

@onready var icon: TextureRect = $Icon

var _duration: float = 1.0
var _elapsed: float = 0.0
var _accent: Color = Color.WHITE
var _texture: Texture2D = null
var _active: bool = false


func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    if _texture != null:
        icon.texture = _texture
    queue_redraw()


func setup(texture: Texture2D, duration: float, accent: Color = Color.WHITE) -> void:
    _texture = texture
    _accent = accent
    _duration = maxf(duration, 0.05)
    _elapsed = 0.0
    _active = true
    if is_node_ready():
        icon.texture = texture
    modulate.a = 1.0
    queue_redraw()


func _process(delta: float) -> void:
    if not _active:
        return

    _elapsed = minf(_elapsed + delta, _duration)
    var remaining := _duration - _elapsed

    if remaining <= warning_duration:
        var blink_phase := fmod(_elapsed * blink_rate, 1.0)
        modulate.a = 1.0 if blink_phase < 0.5 else 0.15
    else:
        modulate.a = 1.0

    queue_redraw()

    if remaining <= 0.0:
        _active = false
        finished.emit()
        queue_free()


func _draw() -> void:
    var center := size * 0.5
    var radius := minf(size.x, size.y) * 0.5 - ring_width
    if radius <= 0.0:
        return

    var base_color := _accent.darkened(0.68)
    base_color.a = 0.8
    draw_circle(center, radius, base_color)

    var progress := clampf(_elapsed / _duration, 0.0, 1.0)
    if progress > 0.0:
        var start_angle := -PI * 0.5
        var points := PackedVector2Array()
        points.append(center)
        for step in range(65):
            var angle := start_angle + TAU * progress * float(step) / 64.0
            points.append(center + Vector2(cos(angle), sin(angle)) * radius)
        draw_colored_polygon(points, Color(_accent.r, _accent.g, _accent.b, 0.72))
        draw_circle(center, 2.0, Color(_accent.r, _accent.g, _accent.b, 0.9))

    draw_arc(
        center,
        radius,
        0.0,
        TAU,
        64,
        Color(_accent.r, _accent.g, _accent.b, 0.55),
        2.0,
        true
    )
