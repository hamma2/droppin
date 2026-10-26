extends RemoteTransform2D
class_name RemoteTransformFollower

@export var radius = 75.0
@export var pos_x = 50.0
@export var remote_node_path: NodePath

func _process(_delta) -> void:
    if remote_node_path:
        var target = get_node(remote_node_path)
        if target:
            global_position = target.global_position + Vector2(pos_x, -radius)
            rotation = 0
