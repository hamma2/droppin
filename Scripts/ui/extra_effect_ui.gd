extends GridContainer

const INDICATOR_SCENE = preload("res://Scenes/ui/ExtraEffectIndicator.tscn")
const COLUMNS: int = 4
const INDICATOR_SIZE: float = 72.0
const SEPARATION: float = 8.0
const RIGHT_MARGIN: float = 36.0


func _ready() -> void:
    columns = COLUMNS
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _align_to_right()


func add_effect(texture: Texture2D, duration: float, accent: Color = Color.WHITE) -> void:
    if texture == null or duration <= 0.0:
        return

    var indicator = INDICATOR_SCENE.instantiate()
    add_child(indicator)
    indicator.setup(texture, duration, accent)
    indicator.tree_exited.connect(_align_to_right)
    _align_to_right()


func _align_to_right() -> void:
    if not is_inside_tree():
        return

    var used_columns := mini(maxi(get_child_count(), 1), COLUMNS)
    var row_width := float(used_columns) * INDICATOR_SIZE
    row_width += float(used_columns - 1) * SEPARATION
    position.x = get_viewport_rect().size.x - RIGHT_MARGIN - row_width
