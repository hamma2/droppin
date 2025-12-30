extends Camera2D

var camera_speed = 2 # the speed of the camera movement
@export var player = null
@export var target_pos = 0

func _ready():
	player = $"../Player"
	target_pos = Vector2(player.position.x+400, 0)

func _physics_process(delta):
	# get the target position of the camera based on the player position and the offset
	if player!=null:
		print("player position: ", player.position)
		target_pos = Vector2(player.position.x+400, 0)
	# lerp the current position of the camera to the target position with a smoothing factor
	position = position.lerp(target_pos, delta * camera_speed)
