extends LeaderboardView

func _ready() -> void:
    visible = false
    var game_manager: Node = find_parent("GameManager")
    if game_manager != null:
        game_manager.connect("game_over_signal", _on_game_over)
    else:
        push_error("GameOverLeaderboard requires a GameManager parent")

func _on_game_over() -> void:
    visible = true
    show_scores(Leaderboard.last_level, Leaderboard.last_rank)
