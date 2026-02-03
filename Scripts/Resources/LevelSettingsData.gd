class_name LevelSettingsData extends Resource

## Datenklasse für Level Settings
# BarrierGenerator Script
## Liste der ExtraData Objekte, die in diesem Level spawnen können
@export var extra_data_list: Array[ExtraData] = []

@export var level_name: String = "Level 1"

@export var gap_width_scale: float = 3.0

@export var barrier_spacing_scale: float = 0.3

@export var spawn_interval_scale: float = 1.0

# BallCamera Script
@export var speed_increase: float = 1.0  # Pixel pro Sekunde Erhöhung

@export var base_speed: float = 350.0

# Ball Script
@export var gravity_scale: float = 5.0

@export var ball_bounce: float = 0.56

@export var ball_friction: float = 0.3

@export var performance_monitoring_enabled: bool = false

func _init(p_extra_data_list: Array[ExtraData] = [], p_level_name: String = "Level 1",
            p_gravity_scale: float = 1.0, p_barrier_spacing_scalegap_width_scale: float = 3.0,
            p_barrier_spacing_scale: float = 0.3, p_spawn_interval_sclae: float = 350, 
            p_base_speed: float = 350.0, p_speed_increase: float = 1.0, p_ball_bounce: float = 0.56,
            p_ball_friction: float = 0.3, p_performance_monitoring_enabled: bool = false
            ) -> void:
    extra_data_list = p_extra_data_list
    level_name = p_level_name
    gravity_scale = p_gravity_scale
    gap_width_scale = p_barrier_spacing_scalegap_width_scale
    barrier_spacing_scale = p_barrier_spacing_scale
    spawn_interval_scale = p_spawn_interval_sclae
    base_speed = p_base_speed
    speed_increase = p_speed_increase
    ball_bounce = p_ball_bounce
    ball_friction = p_ball_friction
    performance_monitoring_enabled = p_performance_monitoring_enabled