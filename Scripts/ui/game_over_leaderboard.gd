extends LeaderboardView

const RANK_COLORS := {
    1: Color(0.98, 0.82, 0.35),
    2: Color(0.82, 0.9, 1.0),
    3: Color(1.0, 0.6, 0.28),
}
const DEFAULT_COLOR := Color(0.96, 0.84, 0.5)
const PULSE_DURATION: float = 6.0
const GOLD := Color(0.96, 0.79, 0.33)
const DARK_OUTLINE := Color(0.16, 0.08, 0.02)
const HIGHLIGHT_GOLD := Color(1.0, 0.9, 0.55)

@export var places_shown: int = 5

@onready var place_label: Label = get_node_or_null("../PlaceLabel")
@onready var fireworks: Node = get_node_or_null("../Fireworks")

var _base_color: Color = DEFAULT_COLOR
var _pulse_time: float = 0.0
var _celebrating: bool = false

func _ready() -> void:
    max_entries = places_shown
    entry_font_size = 30
    visible = false
    if place_label != null:
        place_label.visible = false
    _style_heading()
    var game_manager: Node = find_parent("GameManager")
    if game_manager != null:
        game_manager.connect("game_over_signal", _on_game_over)
    else:
        push_error("GameOverLeaderboard requires a GameManager parent")

func _style_entry_label(label: Label, highlight: bool) -> void:
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.add_theme_color_override("font_outline_color", DARK_OUTLINE)
    label.add_theme_constant_override("outline_size", 7)
    label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.55))
    label.add_theme_constant_override("shadow_offset_x", 0)
    label.add_theme_constant_override("shadow_offset_y", 3)
    label.add_theme_color_override("font_color", HIGHLIGHT_GOLD if highlight else GOLD)

func _style_heading() -> void:
    if title_label == null:
        return
    title_label.add_theme_font_size_override("font_size", 36)
    title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title_label.add_theme_color_override("font_color", GOLD)
    title_label.add_theme_color_override("font_outline_color", DARK_OUTLINE)
    title_label.add_theme_constant_override("outline_size", 8)
    title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.55))
    title_label.add_theme_constant_override("shadow_offset_x", 0)
    title_label.add_theme_constant_override("shadow_offset_y", 4)

func _process(delta: float) -> void:
    if not _celebrating or place_label == null or not place_label.visible:
        return

    _pulse_time += delta
    if _pulse_time >= PULSE_DURATION:
        _celebrating = false
        place_label.scale = Vector2.ONE
        place_label.add_theme_color_override("font_color", _base_color)
        return

    place_label.pivot_offset = place_label.size * 0.5
    var pulse: float = 1.0 + 0.045 * sin(_pulse_time * 4.5)
    place_label.scale = Vector2(pulse, pulse)

    var shimmer: float = 0.5 + 0.5 * sin(_pulse_time * 2.6)
    place_label.add_theme_color_override(
        "font_color", _base_color.lerp(Color(1.0, 1.0, 1.0), 0.12 + shimmer * 0.3)
    )

func _on_game_over() -> void:
    visible = true
    show_scores(Leaderboard.last_level, Leaderboard.last_rank)

    var rank: int = Leaderboard.last_rank
    if place_label == null or rank <= 0:
        return

    _base_color = RANK_COLORS.get(rank, DEFAULT_COLOR)
    place_label.text = "Your place: %d" % rank
    place_label.add_theme_color_override("font_color", _base_color)
    place_label.add_theme_color_override("font_outline_color", _base_color.darkened(0.78))
    place_label.visible = true

    _pulse_time = 0.0
    _celebrating = true

    if rank <= 3 and fireworks != null and fireworks.has_method("celebrate"):
        fireworks.call("celebrate", rank)
