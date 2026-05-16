extends Area2D
class_name CollectibleExtrasEffects

@onready var effectsScript: EffectScript = $/root/PlayScene/EffectScript

var texture: Texture = null
var effectName: String = ""
var _scale: Vector2 = Vector2(1, 1)
var shape: Shape2D = RectangleShape2D.new()
var shape_size: Vector2 = Vector2(128, 128)

var key: Key = Key.KEY_0

func init_it(p_texture: Texture, p_effectName: String = "generic", p_scale: Vector2 = Vector2(1, 1), p_shape: Shape2D = RectangleShape2D.new(), p_shape_size: Vector2 = Vector2(128, 128)) -> void:
    self.texture = p_texture
    self.effectName = p_effectName
    self._scale = p_scale
    self.shape = p_shape
    self.shape_size = p_shape_size

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    instantiate_collectible_extras_effects(texture, _scale, shape, shape_size)
    add_to_group("collectible_extras_effects")
    $/root/PlayScene/GameManager.game_over_signal.connect(_destroy_node_on_gameover)

# overwrite the function in inherited class
func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
    if ((event is InputEventMouseButton and event.is_pressed()) or (event is InputEventKey and event.is_pressed())):
        if(event is InputEventKey && event.keycode != key):
            return

        match effectName:
            "drop_barrier":
                effectsScript.activate_drop_barrier_effect()
            "generic":
                print("No specific effect found for ", effectName, ". Activating generic effect.")

        effectsScript.remove_item(effectsScript.items.find({"name": effectName, "key": key}))
        queue_free()

func instantiate_collectible_extras_effects(_texture: Texture, p_scale: Vector2, _shape: Shape2D, _shape_size: Vector2) -> void:
    if(effectsScript.items.size() >= 4):
        #print("Maximum number of active effects reached. Cannot instantiate more CollectibleExtrasEffects.")
        queue_free()
        return

    set_collision_shape(_shape, _shape_size)

    var viewport_size = get_viewport().get_visible_rect().size
    var lower_left_screen = Vector2(viewport_size.x * 0.1, viewport_size.y * 0.92)
    var _position = lower_left_screen

    while is_spot_occupied(_position, get_node("CollisionShape2D").shape):
        #print("Cannot place CollectibleExtrasEffects at ", _position, " because the spot is occupied.")
        _position += Vector2(_shape_size.x + 20, 0)  # Move right to try another position
        if _position.x > viewport_size.x or _position.x+_shape_size.x > viewport_size.x:
            #print("No available space to place CollectibleExtrasEffects.")
            queue_free()  # Remove the node if no space is available
            return

        if _position.y == 0:
            #print("No available space to place CollectibleExtrasEffects.")
            queue_free()
            return

    if(_position.x > 0 && _position.x < viewport_size.x * 0.1 + 10):
        key = Key.KEY_1
    elif(_position.x > viewport_size.x * 0.1 + 10 && _position.x < viewport_size.x * 0.1 + 10 + _shape_size.x + 20):
        key = Key.KEY_2
    elif(_position.x > viewport_size.x * 0.1 + 10 + _shape_size.x + 20 && _position.x < viewport_size.x * 0.1 + 10 + 2*(_shape_size.x + 20)):
        key = Key.KEY_3
    elif(_position.x > viewport_size.x * 0.1 + 10 + 2*(_shape_size.x + 20) && _position.x < viewport_size.x * 0.1 + 10 + 3*(_shape_size.x + 20)):
        key = Key.KEY_4

    global_position = _position
    set_sprite(_texture, p_scale)

    effectsScript.add_item({
        "name": effectName,
        "key": key,
    })

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
