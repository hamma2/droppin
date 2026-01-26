extends CharacterBody2D
class_name ExtraItem

## Funktionsklasse für generische spawnable Extra Items
## Bewegung, Kollisionserkennung und Effekt-Triggering

## Signal wenn das Extra gesammelt wird
signal collected(extra_item: ExtraItem)

## Signal wenn das Extra zerstört wird (z.B. Decke treffen)
signal destroyed(extra_item: ExtraItem)

@export var movement_speed: float = 150.0

var extra_data: ExtraData ## ExtraData
var direction: int = 1 # 1 für rechts, -1 für links
var viewport_left: float = 0.0
var viewport_right: float = 0.0
var is_collected: bool = false

func _ready():
    # Area2D für Kollisionserkennung mit dem Ball
    if not has_node("Area2D/CollisionShape2D"):
        push_error("ExtraItem benötigt eine CollisionShape2D als Child!")

    # Zufällige Bewegungsrichtung
    direction = [-1, 1][randi() % 2]

    # Verbinde mit Ball-Kollisionen
    if has_node("Area2D"):
        var area = $Area2D
        area.body_entered.connect(_on_area_entered)

func set_extra_data(data: Resource) -> void:
    """Setzt die Extra-Daten und aktualisiert die visuelle Darstellung"""
    extra_data = data

    if extra_data and extra_data.texture:
        if has_node("Sprite2D"):
            $Sprite2D.texture = extra_data.texture
            $Sprite2D.modulate = extra_data.color
            $Sprite2D.scale = Vector2.ONE * extra_data.scale_factor

    if extra_data.collect_animation != null:
        extra_data.collect_animation.connect("animation_finished", Callable(self, "_on_animation_finished"))

func set_viewport_bounds(left: float, right: float) -> void:
    """Setzt die Grenzen für horizontale Bewegung"""
    viewport_left = left
    viewport_right = right

func _physics_process(_delta: float) -> void:
    if is_collected:
        return

    # Horizontale Bewegung
    velocity.x = movement_speed * direction
    velocity.y = 0.0

    var collision = move_and_slide()

    # Überprüfe ob wir die Decke treffen
    if collision:
        var collider = get_last_slide_collision().get_collider()
        if collider and (collider.name == "Ceiling" or collider.is_in_group("ceiling")):
            destroy_without_effect()
            return

    # Richtung wechseln wenn Viewport-Grenze erreicht
    if position.x <= viewport_left:
        direction = 1
        if(extra_data.rotation_change != 0.0):
            rotate_deg(extra_data.rotation_change)
    elif position.x >= viewport_right:
        direction = -1
        if(extra_data.rotation_change != 0.0):
            rotate_deg(extra_data.rotation_change)

func rotate_deg(_deg):
    # Create a tween that exists for this node
    var tween = create_tween()
    # Rotate 180 degrees over 1 second
    tween.tween_property(self, "rotation_degrees", _deg, 1.0)
    # Set easing for smoother animation
    tween.set_ease(Tween.EASE_IN_OUT)

func _on_area_entered(body: Node) -> void:
    """Wird aufgerufen wenn der Ball dieses Extra trifft"""
    if is_collected:
        return

    if body is RigidBody2D and body.name == "Ball":
        collect()

func collect() -> void:
    """Sammelt das Extra ein und ruft die Effekt-Funktion auf"""
    if is_collected:
        return

    is_collected = true
    collected.emit(self)

    # Rufe die Effekt-Funktion auf
    apply_effect()

    # Play the death animation
    if extra_data.collect_animation != null:
        extra_data.animation.play("death")
    else:
        queue_free()

func destroy_without_effect() -> void:
    """Zerstört das Extra ohne Effekt auszulösen (z.B. wenn Decke getroffen wird)"""
    if is_collected:
        return

    is_collected = true
    destroyed.emit(self)
    queue_free()

# This function is automatically called when any animation finishes playing
func _on_animation_finished():
    # Ensure it is the correct animation that finished
    if extra_data.animation == "death":
        # Delete the object from the scene tree
        queue_free()

func apply_effect() -> void:
    """Abstrakte Effekt-Funktion - wird von abgeleiteten Klassen überschrieben oder von außen genutzt"""
    if extra_data:
        # Hier können unterschiedliche Effekte je nach effect_type aufgerufen werden
        match extra_data.effect_type:
            "shield":
                _effect_shield()
            "speed_boost":
                _effect_speed_boost()
            "points":
                _effect_points()
            _:
                _effect_generic()

func _effect_shield() -> void:
    """Beispiel: Shield-Effekt"""
    print("Shield aktiviert für %.1f Sekunden" % extra_data.effect_strength)

func _effect_speed_boost() -> void:
    """Beispiel: Speed-Boost-Effekt"""
    print("Speed Boost: +%.1f" % extra_data.effect_strength)

func _effect_points() -> void:
    """Beispiel: Punkte-Effekt"""
    print("Punkte gewonnen: %.0f" % (extra_data.effect_strength * 100))

func _effect_generic() -> void:
    """Generischer Effekt"""
    print("Generischer Extra-Effekt gesammelt: %s" % extra_data.effect_type)
