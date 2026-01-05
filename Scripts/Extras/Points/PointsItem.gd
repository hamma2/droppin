extends ExtraItem
class_name PointsItem

# Declare a variable and assign the node reference when ready
@onready var effectsScript: EffectScript = $/root/PlayScene/EffectScript

func apply_effect() -> void:
    """Sammelt Punkte ein"""
    if extra_data:
        var points_add = int(extra_data.effect_points)
        if effectsScript != null:
            effectsScript.points_adder(points_add)

        var points_multiplier = float(extra_data.point_multiplier)
        if points_multiplier > 1.0 and effectsScript != null:
            effectsScript.points_multiplier(points_multiplier, extra_data.duration)
