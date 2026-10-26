extends Node

# Emitted whenever an inventory slot key was rebound or swapped.
signal inventory_keys_changed

const SETTINGS_FILE = "user://settings.cfg"
const RESERVED_KEYS: Array = [Key.KEY_W, Key.KEY_A, Key.KEY_S, Key.KEY_D, Key.KEY_LEFT, Key.KEY_RIGHT, Key.KEY_UP, Key.KEY_DOWN]

var themeName: ThemeNames = ThemeNames.skycard
var diffucultyLevel: Difficulty = Difficulty.easy
var selectedLevel: int = 0

var themeSettings: LevelThemeData = null

var inventoryKeys: Array = [Key.KEY_1, Key.KEY_2, Key.KEY_3, Key.KEY_4]

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

func get_level_settings_path(level: int) -> String:
    return "res://StaticData/Levels/Level_%d/Level_%d_settings.tres" % [level, level]

func get_level_theme_path(level: int) -> String:
    return "res://StaticData/Levels/Level_%d/Level_%d_theme.tres" % [level, level]

func get_active_theme_path() -> String:
    if selectedLevel > 0:
        return get_level_theme_path(selectedLevel)
    return themePaths.get(themeName, "")

enum Difficulty{
    easy,
    medium,
    hard,
    impossible
}

func _ready() -> void:
    load_settings()

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

func save_inventory_keys() -> void:
    var config = ConfigFile.new()

    var err = config.load(SETTINGS_FILE)
    if err != OK:
        print("No settings file found. Using default settings and writing file.")

    config.set_value("Inventory", "slot_keys", inventoryKeys)

    config.save(SETTINGS_FILE)

func set_inventory_key(slot_index: int, key: Key) -> bool:
    if slot_index < 0 or slot_index >= inventoryKeys.size():
        return false
    if key <= Key.KEY_NONE or RESERVED_KEYS.has(key):
        return false
    if inventoryKeys[slot_index] == key:
        return true

    var previous_key: Key = inventoryKeys[slot_index]
    var other_slot: int = inventoryKeys.find(key)
    inventoryKeys[slot_index] = key
    if other_slot != -1:
        inventoryKeys[other_slot] = previous_key
    save_inventory_keys()
    inventory_keys_changed.emit()
    Inventory.notify_keys_changed()
    return true

func load_settings() -> void:
    var config = ConfigFile.new()

    var err = config.load(SETTINGS_FILE)
    if err != OK:
        print("No settings file found. Using default settings and writing file.")

    themeName = config.get_value("Theme", "theme_name", ThemeNames.skycard)
    diffucultyLevel = config.get_value("Difficulty", "difficulty_level", Difficulty.easy)

    var slot_keys = config.get_value("Inventory", "slot_keys", [])
    if slot_keys.size() == inventoryKeys.size():
        for i in slot_keys.size():
            var key_value = int(slot_keys[i])
            var plausible = key_value >= Key.KEY_SPACE and key_value < (1 << 25)
            if plausible and not RESERVED_KEYS.has(key_value) and not inventoryKeys.has(key_value):
                inventoryKeys[i] = key_value
