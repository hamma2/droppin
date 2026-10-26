extends Control

const SCORE_RATE_RESPONSE: float = 5.0
const MIN_SCORE_RATE: float = 140.0
const MAX_SCORE_RATE: float = 1600.0
const MIN_FIREWORK_INTENSITY: float = 0.06

@onready var value_label: Label = $Value

var _game_manager: Node = null
var _fireworks: Node = null
var _last_score: int = 0
var _pending_points: int = 0
var _score_rate: float = 0.0
var _firework_cooldown: float = 0.0

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _fireworks = get_node_or_null("../Fireworks")

    _game_manager = find_parent("GameManager")
    if _game_manager != null and _game_manager.has_signal("score_changed"):
        _last_score = _game_manager.score
        _game_manager.score_changed.connect(_on_score_changed)
        _update_text(_last_score)

func _process(delta: float) -> void:
    if delta <= 0.0:
        return

    var instant_rate: float = float(_pending_points) / delta
    _pending_points = 0
    _score_rate = lerpf(_score_rate, instant_rate, 1.0 - exp(-SCORE_RATE_RESPONSE * delta))
    _firework_cooldown = maxf(_firework_cooldown - delta, 0.0)

    if _fireworks == null or not _fireworks.has_method("burst_around"):
        return
    if _firework_cooldown > 0.0:
        return

    var intensity: float = clampf(
        (_score_rate - MIN_SCORE_RATE) / (MAX_SCORE_RATE - MIN_SCORE_RATE), 0.0, 1.0
    )
    if intensity < MIN_FIREWORK_INTENSITY:
        return

    var center: Vector2 = get_global_rect().get_center() - _fireworks.global_position
    var extents: Vector2 = size * 0.5 + Vector2(6.0, 6.0)
    _fireworks.call("burst_around", center, extents, intensity)
    _firework_cooldown = lerpf(0.45, 0.06, intensity)

func _on_score_changed(new_score: int) -> void:
    var gained: int = maxi(new_score - _last_score, 0)
    _last_score = new_score
    _pending_points += gained
    _update_text(new_score)

func _update_text(new_score: int) -> void:
    value_label.text = "Score: " + str(new_score)
