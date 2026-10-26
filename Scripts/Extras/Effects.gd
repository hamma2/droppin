extends Node
class_name EffectScript

## This script contains effects that need to be applied from Extras
## They can run independently from the ExtraItem scripts
## Because after effect application the ExtraItem might be destroyed

# get all necesary game scripts
@onready var gameManager: GameManager = $/root/PlayScene/GameManager
@onready var playerBall: Ball = $/root/PlayScene/Ball
@onready var barrierGenerator: BarrierGenerator = $/root/PlayScene/BarrierGenerator

func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    pass

func show_effect_indicator(data: ExtraData, duration: float) -> void:
    if data == null or data.texture == null or duration <= 0.0:
        return

    var ui_control: Node = get_node_or_null("/root/PlayScene/GameManager/UI/Control")
    if ui_control == null:
        return

    var indicators: Node = ui_control.get_node_or_null("EffectIndicators")
    if indicators != null and indicators.has_method("add_effect"):
        indicators.call("add_effect", data.texture, duration, data.color)

# Function Points addding
# Addiert Punkte und multipliziert sie mit dem aktiven Multiplikator
func points_adder(add: int) -> void:
    if gameManager != null:
        gameManager.points_to_add += add

# Function for multiplying points for a certain time
# only one mutliplicator can be active at a time
# mutliplicator will be the last collected item
func points_multiplier(mul: float, duration: float, data: ExtraData = null) -> void:
    if gameManager != null:
        gameManager.score_mutiplier = mul
        show_effect_indicator(data, duration)
        await get_tree().create_timer(duration).timeout
        gameManager.score_mutiplier = 1.0

# Function for reversing ball direction
func reverse_ball_direction(duration: float, data: ExtraData = null) -> void:
    playerBall.direction = -1
    show_effect_indicator(data, duration)
    await get_tree().create_timer(duration).timeout
    playerBall.direction = 1

# Function for invisible barriers effect
func invisible_barriers(effect_invisible_duration: float, number_blink_times: int, visible_duration: float, data: ExtraData = null) -> void:
    var total_duration: float = float(number_blink_times) * (effect_invisible_duration + visible_duration)
    show_effect_indicator(data, total_duration)
    for i in number_blink_times:
        barrierGenerator.barriers_invisible = true
        await get_tree().create_timer(effect_invisible_duration).timeout
        barrierGenerator.barriers_invisible = false
        await get_tree().create_timer(visible_duration).timeout

func invisible_ball(effect_invisible_duration: float, number_blink_times: int, visible_duration: float, data: ExtraData = null) -> void:
    var total_duration: float = float(number_blink_times) * (effect_invisible_duration + visible_duration)
    show_effect_indicator(data, total_duration)
    for i in number_blink_times:
        playerBall.visible = false
        await get_tree().create_timer(effect_invisible_duration).timeout
        playerBall.visible = true
        await get_tree().create_timer(visible_duration).timeout

func gap_passing(duration: float, degrees: int, degrees2: int, data: ExtraData = null) -> void:
    playerBall.can_pass_gap_effect = true
    playerBall.degrees = degrees
    playerBall.degrees2 = degrees2
    show_effect_indicator(data, duration)
    await get_tree().create_timer(duration).timeout
    playerBall.can_pass_gap_effect = false

# You can set the layer property directly by adding these values together.
#
# Godot Forum
# Layer 1: 1
# Layer 2: 2
# Layer 3: 4
# Layer 4: 8
func activate_drop_barrier_effect() -> void:
    playerBall.collision_layer = 4 # Sets the object to be on Layer 3 only
    playerBall.collision_mask = 4 # Sets the object to only collide with Layer 3 (walls)
    await get_tree().create_timer(0.3).timeout
    playerBall.collision_layer = 5 # Sets the object to be on Layer 1 and Layer 3 (1 + 4 = 5)
    playerBall.collision_mask = 5 # Sets the object to only collide with Layer 1 and Layer 3 (1 + 4 = 5)
    pass
