extends Node

const SETTINGS_FILE = "user://settings.cfg"

var themeName: ThemeNames = ThemeNames.skycard
var diffucultyLevel: Difficulty = Difficulty.easy

var themeSettings: LevelThemeData = null

enum ThemeNames{
    skycard,
    water
}

var themePaths: Dictionary [int, String] = {
    ThemeNames.skycard: "res://StaticData/Levels/Level_1/Level_1_theme.tres",
    ThemeNames.water: "res://StaticData/Levels/Level_1/Level_1_theme.tres",
}

var uiThemePaths: Dictionary [int, String] = {
    ThemeNames.skycard: "res://Materials/sky_postcard_theme/sky_card_ui_theme.tres",
    ThemeNames.water: "res://Materials/sky_postcard_theme/sky_card_ui_theme.tres",
}

enum Difficulty{
    easy,
    medium,
    hard,
    impossible
}

# Saving
func save_theme_settings(theme_name: ThemeNames) -> void:
    var config = ConfigFile.new()

    var err = config.load(SETTINGS_FILE)
    if err != OK:
        print("No settings file found. Using default settings and writing file.")

    config.set_value("Theme", "theme_name", theme_name)

    config.save(SETTINGS_FILE)

func save_difficulty_settings(difficulty_name: Difficulty) -> void:
    var config = ConfigFile.new()

    var err = config.load(SETTINGS_FILE)
    if err != OK:
        print("No settings file found. Using default settings and writing file.")

    config.set_value("Difficulty", "difficulty_level", difficulty_name)
    print("saving difficulty: ", difficulty_name)

    config.save(SETTINGS_FILE)

func load_settings() -> void:
    var config = ConfigFile.new()

    var err = config.load(SETTINGS_FILE)
    if err != OK:
        print("No settings file found. Using default settings and writing file.")

    themeName = config.get_value("Theme", "theme_name", ThemeNames.skycard)
    diffucultyLevel = config.get_value("Difficulty", "difficulty_level", Difficulty.easy)
