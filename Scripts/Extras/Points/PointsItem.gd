extends ExtraItem
class_name PointsItem

# Declare a variable and assign the node reference when ready
@onready var gameManager: GameManager = $/root/PlayScene/GameManager

func apply_effect() -> void:
    """Sammelt Punkte ein"""
    if extra_data:
        var points_add = int(extra_data.effect_points)
        if gameManager != null:
            gameManager.score += points_add
            print("Punkte gewonnen: %d" % points_add)

        var points_multiplier = float(extra_data.point_multiplier)
        if points_multiplier > 1.0 and gameManager != null:
            gameManager.score = int(gameManager.score * points_multiplier)
            print("Punkte-Multiplikator angewendet: x%.1f" % points_multiplier)
