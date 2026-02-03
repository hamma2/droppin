extends Node
class_name GameManager

var ball: Node2D
var barrier_generator: Node2D
var camera: Camera2D

# Define a signal that sends the new score value
signal score_changed(new_score: int)
signal game_over_signal()

var score: int = 0:
    set(value):
        score = value
        # Emit the signal whenever the score value is set
        emit_score_changed(score)

var score_mutiplier: float = 1.0
var points_to_add: int = 0
var prev_y_position: float = 0.0

var game_active: bool = true

@export var end_game_on_ceiling_hit: bool = true

@export var levelSettings: LevelSettingsData = null
@export var themeSettings: LevelThemeData = null

func _ready():
    ball = get_parent().find_child("Ball")
    barrier_generator = get_parent().find_child("BarrierGenerator")
    camera = get_parent().find_child("Camera2D")

    if ball == null:
        push_error("Ball nicht gefunden!")
    if barrier_generator == null:
        push_error("BarrierGenerator nicht gefunden!")
    if camera == null:
        push_error("BallCamera nicht gefunden!")
    if levelSettings == null:
        push_error("LevelSettings nicht gesetzt!")
    if themeSettings == null:
        push_error("ThemeSettings nicht gesetzt!")

    if ball != null:
        ball.connect("hit_ceiling", Callable(self, "_on_ball_hit_ceiling"))
        prev_y_position = ball.position.y

    # set level theme
    if themeSettings != null:
        # set background texture
        var background: Sprite2D = get_parent().find_child("Background_Sprite")
        if background != null and themeSettings.background_texture != null:
            background.texture = themeSettings.background_texture

        # UI instantiation, is needed
        var ui_scene_instance: Node = themeSettings.ui_scene.instantiate()
        if ui_scene_instance != null:
            add_child(ui_scene_instance)

        # instantiate parallax layers
        # not needed to use all of the 5 prototypes, so check for null
        if(themeSettings.parallax_layer_1 != null):
            add_child(themeSettings.parallax_layer_1.instantiate())
        if(themeSettings.parallax_layer_2 != null):
            add_child(themeSettings.parallax_layer_2.instantiate())
        if(themeSettings.parallax_layer_3 != null):
            add_child(themeSettings.parallax_layer_3.instantiate())
        if(themeSettings.parallax_layer_4 != null):
            add_child(themeSettings.parallax_layer_4.instantiate())
        if(themeSettings.parallax_layer_5 != null):
            add_child(themeSettings.parallax_layer_5.instantiate())

        if ball != null and themeSettings.ball_texture != null:
            # set particle collision color
            ball.particle_collision_color = themeSettings.ball_collision_particle_color

            # set ball texture
            var ball_sprite: Sprite2D = ball.find_child("Sprite2D")
            if ball_sprite != null:
                ball_sprite.texture = themeSettings.ball_texture

        # set barrier theme
        if barrier_generator != null:
            if themeSettings.barrier_sprite != null:
                barrier_generator.barrier_texture = themeSettings.barrier_sprite
            if themeSettings.small_barrier_decoration != null:
                barrier_generator.small_barrier_deco_texture = themeSettings.small_barrier_decoration
            if themeSettings.large_barrier_decoration != null:
                barrier_generator.large_barrier_deco_texture = themeSettings.large_barrier_decoration
            if themeSettings.special_barrier_decoration != null:
                barrier_generator.special_barrier_deco_texture = themeSettings.special_barrier_decoration

    # set level settings
    if barrier_generator != null and levelSettings != null:
        barrier_generator.gap_width_scale = levelSettings.gap_width_scale
        barrier_generator.barrier_spacing_scale = levelSettings.barrier_spacing_scale
        barrier_generator.spawn_interval_scale = levelSettings.spawn_interval_scale
        barrier_generator.available_extra_types = (levelSettings.extra_data_list)

    if ball != null and levelSettings != null:
        ball.gravity_scale_factor = levelSettings.gravity_scale
        ball.bounce = levelSettings.ball_bounce
        ball.friction = levelSettings.ball_friction

    if camera != null and levelSettings != null:
        camera.base_speed = levelSettings.base_speed
        camera.speed_increase = levelSettings.speed_increase

func _physics_process(_delta):
    if not game_active or ball == null:
        return

func _process(_delta: float):
    update_score()

func update_score() -> void:
    """Erhöht den Score basierend auf der Y-Position des Balls"""
    var base_increase = int(abs(prev_y_position) - abs(ball.position.y))
    if(base_increase < 0):
        base_increase = 0

    prev_y_position = ball.position.y

    # Addiere manuelle Punkte-Bonuses
    base_increase += points_to_add
    points_to_add = 0 # Reset

    # Wende Multiplikator an
    var score_increase = int(base_increase * score_mutiplier)

    # Nur aktualisieren wenn es echte Punkte gibt
    if base_increase >= 0:
        self.score += score_increase

func emit_score_changed(new_score: int):
    score_changed.emit(new_score)

func game_over():
    """Beendet das Spiel"""
    game_active = false
    print("Game Over! Score: ", score)
    game_over_signal.emit()
    get_tree().paused = true

func reset_game():
    """Setzt das Spiel zurück"""
    score = 0
    game_active = true
    get_tree().paused = false

    if ball != null:
        ball.reset_position(Vector2(400, 100))

    if barrier_generator != null:
        for barrier in barrier_generator.barrier_pairs:
            barrier.queue_free()
        barrier_generator.barrier_pairs.clear()

    get_tree().reload_current_scene()

func increase_difficulty():
    """Erhöht die Schwierigkeit des Spiels"""
    if barrier_generator != null:
        barrier_generator.barrier_spacing_scale = max(0.08, barrier_generator.barrier_spacing_scale - 0.02)
        barrier_generator.barrier_spacing = barrier_generator.screen_size.y * barrier_generator.barrier_spacing_scale

func _on_ball_hit_ceiling():
    """Wird aufgerufen, wenn der Ball die Decke trifft"""
    if end_game_on_ceiling_hit:
        print("Game Over! Ball hat die Decke getroffen! Score: ", score)
        game_over()
    else:
        print("Ball hat die Decke getroffen (testing mode - kein Game Over)")
