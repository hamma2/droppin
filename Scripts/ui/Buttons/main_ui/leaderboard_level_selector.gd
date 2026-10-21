extends OptionButton

func _notification(what: int) -> void:
    if what == NOTIFICATION_VISIBILITY_CHANGED and is_visible_in_tree():
        refresh_levels()

func _ready() -> void:
    item_selected.connect(_on_item_selected)

func refresh_levels() -> void:
    clear()
    var levels: Array[String] = Leaderboard.get_known_levels()
    for level in levels:
        add_item(level)
    if not levels.is_empty():
        select(0)
        _show_view(levels[0])

func _on_item_selected(index: int) -> void:
    _show_view(get_item_text(index))

func _show_view(level: String) -> void:
    var view: LeaderboardView = get_node("../LeaderboardView")
    view.show_scores(level)
