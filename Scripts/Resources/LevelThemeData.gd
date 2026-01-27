class_name LevelThemeData extends Resource

## Datenklasse für Level Settings
## Liste der ExtraData Objekte, die in diesem Level spawnen können
@export var background_texture: Texture2D = null
@export var parallax_layer_1: PackedScene = null
@export var parallax_layer_2: PackedScene = null
@export var parallax_layer_3: PackedScene = null
@export var parallax_layer_4: PackedScene = null
@export var parallax_layer_5: PackedScene = null
@export var ball_texture: Texture2D = null
@export var barrier_sprite : Texture2D = null
@export var small_barrier_decoration: Texture2D = null
@export var large_barrier_decoration: Texture2D = null
@export var special_barrier_decoration: Texture2D = null
@export var ui_scene: PackedScene = null

func _init(p_background_texture: Texture2D = null, p_parallax_layer_1: PackedScene = null,
        p_parallax_layer_2: PackedScene = null, p_parallax_layer_3: PackedScene = null,
        p_parallax_layer_4: PackedScene = null, p_parallax_layer_5: PackedScene = null,
        p_ball_texture: Texture2D = null, p_barrier_sprite: Texture2D = null,
        p_small_barrier_decoration: Texture2D = null, p_large_barrier_decoration: Texture2D = null,
        p_special_barrier_decoration: Texture2D = null, p_ui_scene: PackedScene = null) -> void:
    background_texture = p_background_texture
    parallax_layer_1 = p_parallax_layer_1
    parallax_layer_2 = p_parallax_layer_2
    parallax_layer_3 = p_parallax_layer_3
    parallax_layer_4 = p_parallax_layer_4
    parallax_layer_5 = p_parallax_layer_5
    ball_texture = p_ball_texture
    barrier_sprite = p_barrier_sprite
    small_barrier_decoration = p_small_barrier_decoration
    large_barrier_decoration = p_large_barrier_decoration
    special_barrier_decoration = p_special_barrier_decoration
    ui_scene = p_ui_scene