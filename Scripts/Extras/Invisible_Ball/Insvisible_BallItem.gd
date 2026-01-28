extends ExtraItem
class_name Invisible_BallItem

@onready var effectsScript: EffectScript = $/root/PlayScene/EffectScript

func apply_effect() -> void:
    """Sammelt Punkte ein"""
    if effectsScript != null:
        effectsScript.invisible_ball(extra_data.effect_invisible_duration, extra_data.blink_times,
        extra_data.visible_duration)