extends Node2D
class_name BallMultiplierLabel


@onready var label: Label = $Label
@export var multiplier_color: Color = Color(1, 0.8, 0.2)

var game_manager: GameManager = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if game_manager == null:
        game_manager = get_node("/root/PlayScene/GameManager")

    label.add_theme_color_override("font_color", multiplier_color)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    if game_manager != null:
        var multiplier = game_manager.score_mutiplier
        if multiplier > 1.0:
            label.text = "x" + str(int(multiplier))
            label.visible = true
        else:
            label.visible = false