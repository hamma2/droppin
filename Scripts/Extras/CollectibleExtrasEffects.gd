extends Area2D
class_name CollectibleExtrasEffects

@onready var effectsScript: EffectScript = get_node_or_null("/root/PlayScene/EffectScript")

var texture: Texture = null
var effectName: String = ""
var slot_index: int = -1

func init_it(p_texture: Texture, p_effectName: String = "generic") -> void:
    self.texture = p_texture
    self.effectName = p_effectName

func _ready() -> void:
    instantiate_collectible_extras_effects()

func activate() -> void:
    match effectName:
        "drop_barrier":
            effectsScript.activate_drop_barrier_effect()
        "generic":
            print("No specific effect found for ", effectName, ". Activating generic effect.")
    Inventory.remove_item(self)
    queue_free()

func instantiate_collectible_extras_effects() -> void:
    if not Inventory.add_item(self):
        queue_free()
