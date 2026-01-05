extends ExtraItem
class_name DirectionItem

# Declare a variable and assign the node reference when ready
@onready var effectsScript: EffectScript = $/root/PlayScene/EffectScript

func apply_effect() -> void:
    """Sammelt Punkte ein"""
    if extra_data:
        if effectsScript != null:
            effectsScript.reverse_ball_direction(extra_data.duration)