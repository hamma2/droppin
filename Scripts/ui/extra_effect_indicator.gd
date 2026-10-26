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

    draw_circle(center, radius, Color(0.03, 0.05, 0.08, 0.55))
    draw_arc(center, radius, 0.0, TAU, 64, Color(1.0, 1.0, 1.0, 0.16), ring_width, true)

    var progress := clampf(_elapsed / _duration, 0.0, 1.0)
    if progress > 0.0:
        draw_arc(
            center,
            radius,
            -PI * 0.5,
            -PI * 0.5 + TAU * progress,
            64,
            _accent,
            ring_width,
            true
        )
