extends Node
class_name EffectScript

## This script contains effects that need to be applied from Extras
## They can run independently from the ExtraItem scripts
## Because after effect application the ExtraItem might be destroyed

# get all necesary game scripts
@onready var gameManager: GameManager = $/root/PlayScene/GameManager
@onready var playerBall: Ball = $/root/PlayScene/Ball

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
