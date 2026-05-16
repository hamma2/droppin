extends Area2D
class_name CollectibleExtrasEffects

@onready var effectsScript: EffectScript = $/root/PlayScene/EffectScript

var texture: Texture = null
var effectName: String = ""
var _scale: Vector2 = Vector2(1, 1)
var shape: Shape2D = RectangleShape2D.new()
var shape_size: Vector2 = Vector2(128, 128)

func init_it(p_texture: Texture, p_effectName: String = "generic", p_scale: Vector2 = Vector2(1, 1), p_shape: Shape2D = RectangleShape2D.new(), p_shape_size: Vector2 = Vector2(128, 128)) -> void:
    self.texture = p_texture
    self.effectName = p_effectName
    self._scale = p_scale
    self.shape = p_shape
    self.shape_size = p_shape_size

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    instantiate_collectible_extras_effects(texture, _scale, shape, shape_size)
    $/root/PlayScene/GameManager.game_over_signal.connect(_destroy_node_on_gameover)

# overwrite the function in inherited class
func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
    if (event is InputEventMouseButton and event.is_pressed()) or Input.is_action_pressed("ui_down"):
        match effectName:
            "drop_barrier":
                effectsScript.activate_drop_barrier_effect()
            "generic":
                print("No specific effect found for ", effectName, ". Activating generic effect.")

        queue_free()
        pass

func instantiate_collectible_extras_effects(_texture: Texture, p_scale: Vector2, _shape: Shape2D, _shape_size: Vector2) -> void:
    set_collision_shape(_shape, _shape_size)

    var viewport_height = get_viewport().size.y
    var lower_left_screen = Vector2(0, viewport_height)
    lower_left_screen.y -= _shape_size.y / 2 + 30  # Adjust for shape size to avoid placing it partially off-screen
    lower_left_screen.x += _shape_size.x / 2 + 20  # Add some padding from the left edge
    var _position = lower_left_screen

    while is_spot_occupied(_position, get_node("CollisionShape2D").shape):
        #print("Cannot place CollectibleExtrasEffects at ", _position, " because the spot is occupied.")
        _position += Vector2(_shape_size.x + 20, 0)  # Move right to try another position
        if _position.x > get_viewport().size.x or _position.x+_shape_size.x > get_viewport().size.x:
            #print("No available space to place CollectibleExtrasEffects.")
            queue_free()  # Remove the node if no space is available
            return

        if _position.y == 0:
            #print("No available space to place CollectibleExtrasEffects.")
            queue_free()
            return

    position = _position
    set_sprite(_texture, p_scale)

func set_collision_shape(p_shape: Shape2D, p_shape_size: Vector2) -> void:
    var collision_shape: CollisionShape2D = get_node("CollisionShape2D")
    collision_shape.shape = p_shape
    collision_shape.shape.extents = p_shape_size / 2
    collision_shape.disabled = false

func set_sprite(p_texture: Texture, p_scale: Vector2) -> void:
    var sprite: Sprite2D = get_node("Sprite2D")
    sprite.texture = p_texture
    sprite.scale = p_scale

func is_spot_occupied(_position: Vector2, _shape: Shape2D) -> bool:
    var space_state = get_world_2d().direct_space_state
    var query = PhysicsShapeQueryParameters2D.new()

    # Set shape and position to check
    query.shape = _shape
    query.transform = Transform2D(0, _position)
    query.collide_with_areas = true # Specifically check Areas

    # Check for collisions
    var result = space_state.intersect_shape(query)
    return not result.is_empty()

func _destroy_node_on_gameover():
    queue_free()
