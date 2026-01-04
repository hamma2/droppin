extends Node
class_name EffectScript

## This script contains effects that need to be applied from Extras
## They can run independently from the ExtraItem scripts
## Because after effect application the ExtraItem might be destroyed

# get all necesary game scripts
@onready var gameManager: GameManager = $/root/PlayScene/GameManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

# Function Points addding
func points_multiplier(mul: float) -> void:
    print("Starting delay...")
    if gameManager != null:
        gameManager.score_mutiplier = mul
        # This line pauses the function execution until the 3-second timer times out
        await get_tree().create_timer(3.0).timeout
        print("Delay finished! This message prints 3 seconds later.")
        gameManager.score_mutiplier = 1.0
