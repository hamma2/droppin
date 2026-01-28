extends ExtraItem
class_name Invisible_BarriersItem

@onready var effectsScript: EffectScript = $/root/PlayScene/EffectScript

func apply_effect() -> void:
    """Sammelt Punkte ein"""
    if effectsScript != null:
        effectsScript.invisible_barriers(extra_data.effect_invisible_duration, extra_data.blink_times,
        extra_data.visible_duration)