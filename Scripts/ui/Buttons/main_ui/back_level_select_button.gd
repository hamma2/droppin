extends Button


func _ready() -> void:
    pressed.connect(_on_pressed)


func _on_pressed() -> void:
    var main_ui := find_parent("MainUi")
    main_ui.find_child("LevelSelectLabel").visible = false
    main_ui.find_child("BackButtonStart").visible = true
