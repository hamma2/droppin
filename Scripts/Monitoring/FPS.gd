extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var game_manager: Node = find_parent("GameManager")
    await game_manager.ready
    if game_manager._performance_monitoring_enabled:
        visible = true
    else:
        visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    text = "FPS: " + str(Performance.get_monitor(Performance.TIME_FPS))
