extends RemoteTransform2D
class_name RemoteTransformPointsCollector

# Attach this to the RemoteTransform2D
@export var radius = 75.0
@export var pos_x = 50.0
@export var remote_node_path: NodePath

func _process(delta) -> void:
    # Keep label upright and directly above the ball without rotating or orbiting
    if remote_node_path:
        var ball = get_node(remote_node_path)
        if ball:
            global_position = ball.global_position + Vector2(pos_x, -radius)
            rotation = 0
