extends Label

var score: int = 0

func _ready():
    var game_manager: Node = find_parent("GameManager")
    print(game_manager.name)
    game_manager.connect("score_changed", Callable(self, "_on_game_manager_score_changed"))
    _on_game_manager_score_changed(game_manager.score)

func _on_game_manager_score_changed(new_score: int):
    text = "Score: " + str(new_score)