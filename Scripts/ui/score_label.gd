extends Control

@export var count_speed: float = 7.0
@export var theme_score_scale: float = 4500.0

@onready var value_label: Label = $Value

const CARD_COLORS := [
    Color(0.043, 0.145, 0.18, 0.0)
]

const ACCENT_COLORS := [
    Color(0.45, 0.88, 0.8),
    Color(0.99, 0.79, 0.42),
    Color(1.0, 0.55, 0.42),
    Color(0.62, 0.7, 1.0),
]

const STAR_FIELD := [
    Vector3(0.08, 0.2, 0.0),
    Vector3(0.23, 0.62, 1.4),
    Vector3(0.31, 0.16, 2.1),
    Vector3(0.47, 0.72, 0.7),
    Vector3(0.58, 0.22, 1.8),
    Vector3(0.68, 0.55, 2.6),
    Vector3(0.82, 0.18, 0.3),
    Vector3(0.91, 0.46, 1.1),
]

const CLOUDS := [
    Vector4(0.08, 0.3, 6.0, 26.0),
    Vector4(0.42, 0.66, 9.0, 34.0),
    Vector4(0.76, 0.4, 4.5, 22.0),
]

var target_score: int = 0
var displayed_score: float = 0.0

var _shown_score: int = -1
var _visual_energy: float = 0.0
var _pulse: float = 0.0
var _theme_progress: float = 0.0
var _time: float = 0.0
var _game_manager: Node = null

var _card_style := StyleBoxFlat.new()
var _border_style := StyleBoxFlat.new()
var _aura_style := StyleBoxFlat.new()


func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _configure_style(_card_style, 12)
    _configure_style(_border_style, 12)
    _configure_style(_aura_style, 15)
    _border_style.draw_center = false
    _aura_style.draw_center = false

    _game_manager = find_parent("GameManager")
    if _game_manager != null and _game_manager.has_signal("score_changed"):
        _game_manager.score_changed.connect(_on_score_changed)
        _on_score_changed(_game_manager.score)


func _process(delta: float) -> void:
    _time += delta

    var diff := float(target_score) - displayed_score
    if absf(diff) <= 0.5:
        displayed_score = float(target_score)
    else:
        displayed_score += diff * (1.0 - exp(-count_speed * delta))

    var shown := int(round(displayed_score))
    if shown != _shown_score:
        _shown_score = shown
        value_label.text = "Score: " + str(shown)

    var wanted_progress := 1.0 - exp(-float(target_score) / theme_score_scale)
    _theme_progress = lerp(_theme_progress, wanted_progress, 1.0 - exp(-1.8 * delta))
    _visual_energy = move_toward(_visual_energy, 0.0, delta * 1.3)
    _pulse = move_toward(_pulse, 0.0, delta * 2.8)

    queue_redraw()


func _draw() -> void:
    var rect := Rect2(Vector2.ZERO, size)
    var progress := clampf(_theme_progress, 0.0, 1.0)
    var card_color := _sample_palette(CARD_COLORS, progress)
    var accent := _sample_palette(ACCENT_COLORS, progress)
    var energy := clampf(_visual_energy + _pulse * 0.7, 0.0, 1.0)

    _aura_style.border_color = Color(accent.r, accent.g, accent.b, 0.04 * _pulse + 0.05 * energy)
    if _aura_style.border_color.a > 0.015:
        draw_style_box(_aura_style, rect.grow(2.5))

    _card_style.bg_color = card_color.lerp(
        Color(accent.r, accent.g, accent.b, card_color.a), 0.06 + energy * 0.05
    )
    draw_style_box(_card_style, rect)

    _draw_stars(rect, progress)
    _draw_sun(rect, accent, progress, energy)
    _draw_clouds(rect, energy)
    _draw_horizon(rect, accent, progress)

    _border_style.border_color = Color(accent.r, accent.g, accent.b, 0.18 + 0.22 * energy)
    draw_style_box(_border_style, rect.grow(-0.5))


func _on_score_changed(new_score: int) -> void:
    var gained := maxi(new_score - target_score, 0)
    if new_score < target_score:
        displayed_score = float(new_score)

    target_score = new_score
    _visual_energy = minf(1.0, _visual_energy + float(gained) * 0.0016)
    if gained >= 40:
        _pulse = 1.0


func _configure_style(style: StyleBoxFlat, radius: int) -> void:
    style.anti_aliasing = true
    style.corner_radius_top_left = radius
    style.corner_radius_top_right = radius
    style.corner_radius_bottom_right = radius
    style.corner_radius_bottom_left = radius
    style.border_width_left = 1
    style.border_width_top = 1
    style.border_width_right = 1
    style.border_width_bottom = 1


func _sample_palette(colors: Array, progress: float) -> Color:
    if colors.is_empty():
        return Color.WHITE

    var scaled := clampf(progress, 0.0, 1.0) * float(colors.size() - 1)
    var index := int(floor(scaled))
    if index >= colors.size() - 1:
        return colors[colors.size() - 1] as Color

    var weight := smoothstep(0.0, 1.0, scaled - float(index))
    return (colors[index] as Color).lerp(colors[index + 1] as Color, weight)


func _draw_stars(rect: Rect2, progress: float) -> void:
    var night := clampf((progress - 0.52) / 0.48, 0.0, 1.0)
    if night <= 0.01:
        return

    for star in STAR_FIELD:
        var star_data: Vector3 = star
        var twinkle := 0.55 + 0.45 * sin(_time * 1.6 + star_data.z)
        var color := Color(0.85, 0.9, 1.0, night * twinkle * 0.5)
        var point := rect.position + Vector2(
            star_data.x * rect.size.x, star_data.y * rect.size.y
        )
        draw_line(point - Vector2(2.0, 0.0), point + Vector2(2.0, 0.0), color, 1.0, true)
        draw_line(point - Vector2(0.0, 2.0), point + Vector2(0.0, 2.0), color, 1.0, true)


func _draw_sun(rect: Rect2, accent: Color, progress: float, energy: float) -> void:
    var center := rect.position + Vector2(
        rect.size.x - 30.0, rect.size.y * (0.28 + progress * 0.34)
    )
    var glow := 0.6 + energy * 0.4

    for layer in range(4, 0, -1):
        var radius := 4.0 + float(layer) * 4.5 + energy * 5.0
        var alpha := (0.05 + energy * 0.03) / float(layer)
        draw_circle(center, radius, Color(accent.r, accent.g, accent.b, alpha * glow))

    var core_alpha := lerpf(0.9, 0.55, progress)
    draw_circle(center, 4.5, Color(accent.r, accent.g, accent.b, core_alpha))
    draw_circle(
        center + Vector2(-1.2, -1.2), 1.4, Color(1.0, 1.0, 1.0, core_alpha * 0.45)
    )


func _draw_clouds(rect: Rect2, energy: float) -> void:
    for cloud in CLOUDS:
        var cloud_data: Vector4 = cloud
        var span := rect.size.x + 70.0
        var travel: float = fmod(
            cloud_data.x * span + _time * cloud_data.z * (1.0 + energy * 0.7), span
        )
        var x: float = rect.position.x - 35.0 + travel
        var y := (
            rect.position.y
            + rect.size.y * cloud_data.y
            + sin(_time * 0.7 + cloud_data.x * 6.0) * 1.5
        )
        var color := Color(1.0, 1.0, 1.0, 0.08 + energy * 0.04)
        draw_circle(Vector2(x, y), 2.1, color)
        draw_circle(Vector2(x + cloud_data.w * 0.2, y - 1.3), 3.0, color)
        draw_circle(Vector2(x + cloud_data.w * 0.45, y), 1.9, color)


func _draw_horizon(rect: Rect2, accent: Color, progress: float) -> void:
    var y := rect.position.y + rect.size.y - 11.0
    var left := rect.position.x + 16.0
    var right := rect.end.x - 16.0
    var head := lerpf(left, right, progress)

    draw_line(Vector2(left, y), Vector2(right, y), Color(1.0, 1.0, 1.0, 0.06), 1.0, true)
    draw_line(
        Vector2(left, y), Vector2(head, y), Color(accent.r, accent.g, accent.b, 0.32), 2.0, true
    )
    draw_circle(Vector2(head, y), 1.5, Color(accent.r, accent.g, accent.b, 0.55))
