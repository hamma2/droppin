class_name LevelThemeData extends Resource

## Datenklasse für Level Settings
## Liste der ExtraData Objekte, die in diesem Level spawnen können
@export var background_texture: Texture2D = null
@export var parallax_layer_1: Texture2D = null
@export var parallax_layer_2: Texture2D = null
@export var parallax_layer_3: Texture2D = null
@export var parallax_layer_4: Texture2D = null
@export var parallax_layer_5: Texture2D = null
@export var ball_texture: Texture2D = null
@export var barrier_sprite : Texture2D = null
@export var small_barrier_decoration: Texture2D = null
@export var large_barrier_decoration: Texture2D = null
@export var special_barrier_decoration: Texture2D = null

func _init() -> void:
                return