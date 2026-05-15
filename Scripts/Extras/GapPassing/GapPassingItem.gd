extends ExtraItem
class_name GapPassingItem

# Declare a variable and assign the node reference when ready
@onready var effectsScript: EffectScript = $/root/PlayScene/EffectScript

func apply_effect() -> void:
    """Setzt Gap Effect für die definierte Dauer"""
    if extra_data:
        if effectsScript != null:
            effectsScript.gap_passing(extra_data.duration, extra_data.degrees, extra_data.degrees2)