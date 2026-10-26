extends Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var game_manager: Node = find_parent("GameManager")
    await game_manager.ready
    var show_fps: bool = game_manager._performance_monitoring_enabled
    if OS.is_debug_build() and Settings.debugMenuEnabled:
        show_fps = Settings.debugShowFps
    visible = show_fps

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    text = "FPS: " + str(Performance.get_monitor(Performance.TIME_FPS))
