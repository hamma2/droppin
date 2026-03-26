extends OptionButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    item_selected.connect(Callable(self, "_item_selected"))

func _item_selected(sel):
    Settings.save_difficulty_settings(sel)
    