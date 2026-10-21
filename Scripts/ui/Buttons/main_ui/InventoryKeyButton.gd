extends Button

@export var slot_index: int = 0

var _capturing: bool = false

func _ready() -> void:
    pressed.connect(_on_pressed)
    Settings.inventory_keys_changed.connect(_update_text)
    _update_text()

func _on_pressed() -> void:
    _capturing = true
    text = "..."

func _input(event: InputEvent) -> void:
    if not _capturing:
        return
    if event is InputEventMouseButton and event.is_pressed():
        _cancel_capture()
        return
    if event is InputEventKey and event.is_pressed() and not event.is_echo():
        get_viewport().set_input_as_handled()
        _capturing = false
        if Settings.set_inventory_key(slot_index, event.keycode):
            _update_text()
        else:
            _show_rejected()

func _cancel_capture() -> void:
    _capturing = false
    _update_text()

func _show_rejected() -> void:
    text = "X"
    await get_tree().create_timer(0.5).timeout
    if is_inside_tree():
        _update_text()

func _update_text() -> void:
    if slot_index < Settings.inventoryKeys.size():
        text = OS.get_keycode_string(Settings.inventoryKeys[slot_index])
