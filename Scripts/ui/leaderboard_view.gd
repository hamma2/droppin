extends VBoxContainer
class_name LeaderboardView

@export var entry_font_size: int = 22
@export var max_entries: int = 0

var current_level: String = ""
var current_highlight_rank: int = 0

@onready var title_label: Label = $TitleLabel
@onready var entries_box: VBoxContainer = $Entries

func _notification(what: int) -> void:
    if what == NOTIFICATION_VISIBILITY_CHANGED and is_visible_in_tree():
        refresh()

func refresh() -> void:
    if current_level != "":
        _render()

func show_scores(level: String, highlight_rank: int = 0) -> void:
    current_level = level
    current_highlight_rank = highlight_rank
    _render()

func _render() -> void:
    title_label.text = current_level
    for child in entries_box.get_children():
        child.queue_free()

    var level_scores: Array = Leaderboard.get_scores(current_level)
    if level_scores.is_empty():
        entries_box.add_child(_create_entry_label("No scores yet", false))
        return

    var entry_count: int = level_scores.size()
    if max_entries > 0:
        entry_count = mini(entry_count, max_entries)

    var rank: int = 1
    for i in range(entry_count):
        var score_value = level_scores[i]
        entries_box.add_child(_create_entry_label("%d) %d" % [rank, score_value], rank == current_highlight_rank))
        rank += 1

func _create_entry_label(text: String, highlight: bool) -> Label:
    var label := Label.new()
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    label.add_theme_font_size_override("font_size", entry_font_size)
    if highlight:
        label.text = "> " + text
        label.add_theme_color_override("font_color", Color(0.85, 0.55, 0.05))
    else:
        label.text = text
    _style_entry_label(label, highlight)
    return label

func _style_entry_label(_label: Label, _highlight: bool) -> void:
    pass
