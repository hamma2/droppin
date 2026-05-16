extends Node
class_name EffectScript

## This script contains effects that need to be applied from Extras
## They can run independently from the ExtraItem scripts
## Because after effect application the ExtraItem might be destroyed

# get all necesary game scripts
@onready var gameManager: GameManager = $/root/PlayScene/GameManager
@onready var playerBall: Ball = $/root/PlayScene/Ball
@onready var barrierGenerator: BarrierGenerator = $/root/PlayScene/BarrierGenerator

# Stores collectible extra items as a list of dictionaries or Resources
var items = []

func add_item(item_data: Dictionary):
    items.append(item_data)
    print("Added item: ", item_data.name)

func remove_item(index: int):
    if index >= 0 and index < items.size():
        items.remove_at(index)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    pass

# Function Points addding
# Addiert Punkte und multipliziert sie mit dem aktiven Multiplikator
func points_adder(add: int) -> void:
    if gameManager != null:
        gameManager.points_to_add += add

# Function for multiplying points for a certain time
# only one mutliplicator can be active at a time
# mutliplicator will be the last collected item
func points_multiplier(mul: float, duration: float) -> void:
    if gameManager != null:
        gameManager.score_mutiplier = mul
        await get_tree().create_timer(duration).timeout
        gameManager.score_mutiplier = 1.0

# Function for reversing ball direction
func reverse_ball_direction(duration: float) -> void:
    playerBall.direction = -1
    await get_tree().create_timer(duration).timeout
    playerBall.direction = 1

# Function for invisible barriers effect
func invisible_barriers(effect_invisible_duration: float, number_blink_times: int, visible_duration: float) -> void:
    for i in number_blink_times:
        barrierGenerator.barriers_invisible = true
        await get_tree().create_timer(effect_invisible_duration).timeout
        barrierGenerator.barriers_invisible = false
        await get_tree().create_timer(visible_duration).timeout

func invisible_ball(effect_invisible_duration: float, number_blink_times: int, visible_duration: float) -> void:
    for i in number_blink_times:
        playerBall.visible = false
        playerBall.get_node("BallPointsCollector").is_visible = false
        await get_tree().create_timer(effect_invisible_duration).timeout
        playerBall.visible = true
        playerBall.get_node("BallPointsCollector").visible = true
        await get_tree().create_timer(visible_duration).timeout

func gap_passing(duration: float, degrees: int, degrees2: int) -> void:
    playerBall.can_pass_gap_effect = true
    playerBall.degrees = degrees
    playerBall.degrees2 = degrees2
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
