extends Label

const LEVEL_COUNT: int = 10

@onready var level_grid: GridContainer = $LevelGrid


func _ready() -> void:
    for level in range(1, LEVEL_COUNT + 1):
        var settings := load(Settings.get_level_settings_path(level)) as LevelSettingsData
        var level_name := settings.level_name if settings != null else "Level %d" % level

        var button := Button.new()
        button.text = "%d. %s" % [level, level_name]
        button.custom_minimum_size = Vector2(350, 62)
        button.add_theme_font_size_override("font_size", 24)
        button.pressed.connect(_on_level_selected.bind(level))
        level_grid.add_child(button)


func _on_level_selected(level: int) -> void:
    Settings.selectedLevel = level
    get_tree().change_scene_to_file("res://Scenes/main.tscn")
