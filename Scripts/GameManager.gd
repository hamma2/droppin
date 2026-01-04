extends Node
class_name GameManager

var ball: Node2D
var barrier_generator: Node2D
var camera: Camera2D

var score: int = 0
var score_mutiplier: float = 1.0

# Reference to your ScoreLabel node
@onready var score_label: Label = $/root/PlayScene/CanvasLayer/Control/ScoreLabel

var game_active: bool = true

@export var end_game_on_ceiling_hit: bool = true

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

    # GEÄNDERT: Nur Ceiling-Signal verbinden
    if ball != null:
        ball.connect("hit_ceiling", Callable(self, "_on_ball_hit_ceiling"))

func _physics_process(_delta):
    if not game_active or ball == null:
        return

    update_score()

func update_score():
    """Erhöht den Score basierend auf der Y-Position des Balls"""
    var new_score = int(abs(ball.position.y) / 10 * score_mutiplier)
    if new_score > score:
        score = new_score

        # Change Score Label Text
        if(score_label != null):
            score_label.text = "Score: " + str(score)

func game_over():
    """Beendet das Spiel"""
    game_active = false
    print("Game Over! Score: ", score)
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
