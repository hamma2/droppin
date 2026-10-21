extends ExtraItem
class_name DropBarrierItem

func apply_effect() -> void:
    """Applies the effect of the DropBarrierItem, which is to create a CollectibleExtrasEffects instance with the specified texture and scale.
    """
    if extra_data:
        var collectibleInstance = collectibleScene.instantiate()
        if collectibleInstance:
            collectibleInstance.init_it(extra_data.texture, "drop_barrier", Vector2.ONE * extra_data.scale_factor)
            $"/root/PlayScene/GameManager/UI/Control".add_child(collectibleInstance)
