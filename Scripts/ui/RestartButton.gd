extends Button

var game_manager: Node = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self.visible = false
    game_manager = find_parent("GameManager")
    # move on game over to pause menu as subnode of ui node and add this button to it
    game_manager.connect("game_over_signal", Callable(self, "_on_game_over"))
    pressed.connect(Callable(self, "_on_pressed"))

func _on_game_over():
    self.visible = true

func _on_pressed():
    game_manager.reset_game()
