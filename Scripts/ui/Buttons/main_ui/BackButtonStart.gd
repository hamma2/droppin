extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pressed.connect(Callable(self, "_on_pressed"))


func _on_pressed():
    get_parent().find_child("Start").visible = true
    visible = false