extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pressed.connect(Callable(self, "_on_pressed"))


func _on_pressed():
    var main = load("res://Scenes/main.tscn")
    
    get_parent().queue_free()

    