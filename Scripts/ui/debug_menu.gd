extends VBoxContainer

const OPTION_FONT_SIZE: int = 20
const OPTION_MIN_HEIGHT: float = 48.0
const OPTION_SEPARATION: int = 4
const MENU_SEPARATION: int = 6
const BACK_TOP_DEFAULT: float = 880.0
const BACK_TOP_MENU_OPEN: float = 1160.0
const BACK_HEIGHT: float = 94.0

var _back_button: Control = null
var _menu_toggle: CheckButton = null
var _options: VBoxContainer = null
var _reset_leaderboard_button: Button = null


func _ready() -> void:
    _back_button = get_parent().get_node_or_null("Back_to_Main_Menu_Button") as Control

    if not OS.is_debug_build():
        visible = false
        _set_back_top(BACK_TOP_DEFAULT)
        return

    add_theme_constant_override("separation", MENU_SEPARATION)
    _build_menu()


func _build_menu() -> void:
    _menu_toggle = CheckButton.new()
    _menu_toggle.text = "Debug Menu"
    _menu_toggle.button_pressed = Settings.debugMenuEnabled
    _menu_toggle.custom_minimum_size = Vector2(0, OPTION_MIN_HEIGHT)
    _menu_toggle.add_theme_font_size_override("font_size", OPTION_FONT_SIZE)
    _menu_toggle.toggled.connect(_on_menu_toggled)
    add_child(_menu_toggle)

    _options = VBoxContainer.new()
    _options.add_theme_constant_override("separation", OPTION_SEPARATION)
    _options.visible = Settings.debugMenuEnabled
    add_child(_options)

    _add_check("Show FPS", Settings.debugShowFps, _on_show_fps_toggled)
    _add_check("Disable Game Over", Settings.debugDisableGameOver, _on_disable_game_over_toggled)
    _add_check("Show Collision Shapes", Settings.debugShowCollisionShapes, _on_show_collision_shapes_toggled)
    _add_button("Reset Settings", _on_reset_settings)
    _reset_leaderboard_button = _add_button("Reset Leaderboard", _on_reset_leaderboard)

    _layout_back()


func _add_check(label_text: String, pressed: bool, callback: Callable) -> CheckButton:
    var check := CheckButton.new()
    check.text = label_text
    check.button_pressed = pressed
    check.custom_minimum_size = Vector2(0, OPTION_MIN_HEIGHT)
    check.add_theme_font_size_override("font_size", OPTION_FONT_SIZE)
    check.toggled.connect(callback)
    _options.add_child(check)
    return check


func _add_button(label_text: String, callback: Callable) -> Button:
    var button := Button.new()
    button.text = label_text
    button.custom_minimum_size = Vector2(0, OPTION_MIN_HEIGHT)
    button.add_theme_font_size_override("font_size", OPTION_FONT_SIZE)
    button.pressed.connect(callback)
    _options.add_child(button)
    return button


func _on_menu_toggled(enabled: bool) -> void:
    Settings.debugMenuEnabled = enabled
    Settings.save_debug_settings()
    Settings.apply_debug_settings()
    _options.visible = enabled
    _layout_back()


func _on_show_fps_toggled(enabled: bool) -> void:
    Settings.debugShowFps = enabled
    Settings.save_debug_settings()


func _on_disable_game_over_toggled(enabled: bool) -> void:
    Settings.debugDisableGameOver = enabled
    Settings.save_debug_settings()


func _on_show_collision_shapes_toggled(enabled: bool) -> void:
    Settings.debugShowCollisionShapes = enabled
    Settings.save_debug_settings()
    Settings.apply_debug_settings()


func _on_reset_settings() -> void:
    Settings.reset_settings()
    get_tree().reload_current_scene()


func _on_reset_leaderboard() -> void:
    Leaderboard.reset_scores()
    _flash_button(_reset_leaderboard_button, "Leaderboard reset")


func _flash_button(button: Button, message: String) -> void:
    if button == null:
        return

    var original_text: String = button.text
    button.text = message
    button.disabled = true
    await get_tree().create_timer(1.0).timeout
    if is_instance_valid(button):
        button.text = original_text
        button.disabled = false


func _layout_back() -> void:
    if _options != null and _options.visible:
        _set_back_top(BACK_TOP_MENU_OPEN)
    else:
        _set_back_top(BACK_TOP_DEFAULT)


func _set_back_top(top: float) -> void:
    if _back_button == null:
        return
    _back_button.offset_top = top
    _back_button.offset_bottom = top + BACK_HEIGHT
