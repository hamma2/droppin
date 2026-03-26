extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    Settings.load_settings()
    find_child("DifficultyButton").selected = Settings.diffucultyLevel
    find_child("ThemeButton").selected = Settings.themeName
    theme = load(Settings.uiThemePaths.get(Settings.themeName))