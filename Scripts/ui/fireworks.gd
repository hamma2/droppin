extends Control

## Purely visual celebration overlay: bursts of glowing sparks drawn on top of the UI.
## Runs even while the tree is paused so it can fire on the game over screen.

const BURST_SPARKS: int = 48
const MAX_SPARKS: int = 360
const GRAVITY: float = 210.0
const DRAG: float = 1.4
const TAIL_FACTOR: float = 0.045

var _palette: Array[Color] = []
var _sparks: Array[Dictionary] = []
var _bursts: Array[Dictionary] = []
var _time: float = 0.0
var _active: bool = false
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    process_mode = Node.PROCESS_MODE_ALWAYS
    visible = false
    set_process(false)
    _rng.randomize()

func celebrate(rank: int) -> void:
    _palette = _palette_for_rank(rank)
    _sparks.clear()
    _bursts.clear()
    _time = 0.0
    _active = true
    visible = true
    set_process(true)

    var view: Vector2 = get_viewport_rect().size
    var centers: Array[Vector2] = [
        Vector2(view.x * 0.50, view.y * 0.20),
        Vector2(view.x * 0.20, view.y * 0.31),
        Vector2(view.x * 0.80, view.y * 0.29),
        Vector2(view.x * 0.32, view.y * 0.45),
        Vector2(view.x * 0.68, view.y * 0.43),
        Vector2(view.x * 0.50, view.y * 0.36),
        Vector2(view.x * 0.14, view.y * 0.52),
        Vector2(view.x * 0.86, view.y * 0.50),
    ]
    for i in centers.size():
        _bursts.append({"at": 0.12 + float(i) * 0.34, "pos": centers[i]})

## Emits a ring of bursts hugging an ellipse, scaled by an intensity between 0 and 1.
func burst_around(center: Vector2, extents: Vector2, intensity: float) -> void:
    var power: float = clampf(intensity, 0.0, 1.0)
    if power <= 0.02:
        return

    _palette = _gameplay_palette()
    _active = true
    visible = true
    set_process(true)

    var view: Vector2 = get_viewport_rect().size
    var sources: int = 1 + int(round(power * 2.0))
    var sparks: int = int(round(lerpf(10.0, 42.0, power)))
    for i in sources:
        var angle: float = _rng.randf_range(0.0, TAU)
        var offset := Vector2(cos(angle) * extents.x, sin(angle) * extents.y)
        offset *= _rng.randf_range(0.85, 1.05)
        var pos: Vector2 = (center + offset).clamp(Vector2(8.0, 8.0), view - Vector2(8.0, 8.0))
        _burst(pos, sparks, lerpf(0.55, 1.25, power), 0.45)

func _process(delta: float) -> void:
    if not _active:
        return

    _time += delta
    while not _bursts.is_empty() and _time >= float(_bursts[0].at):
        _burst(_bursts[0].pos)
        _bursts.remove_at(0)

    for spark in _sparks:
        var vel: Vector2 = spark.vel
        var pos: Vector2 = spark.pos
        vel.y += GRAVITY * delta
        vel *= maxf(0.0, 1.0 - DRAG * delta)
        pos += vel * delta
        spark.vel = vel
        spark.pos = pos
        spark.life = float(spark.life) - delta

    for i in range(_sparks.size() - 1, -1, -1):
        if float(_sparks[i].life) <= 0.0:
            _sparks.remove_at(i)

    if _bursts.is_empty() and _sparks.is_empty():
        _active = false
        visible = false
        set_process(false)

    queue_redraw()

func _burst(
    center: Vector2, spark_count: int = BURST_SPARKS, power: float = 1.0, speed_scale: float = 1.0
) -> void:
    if _palette.is_empty():
        return

    var count: int = mini(spark_count, maxi(MAX_SPARKS - _sparks.size(), 0))
    var primary: Color = _palette[_rng.randi_range(0, _palette.size() - 1)]
    var secondary: Color = _palette[_rng.randi_range(0, _palette.size() - 1)]

    for i in count:
        var angle: float = _rng.randf_range(0.0, TAU)
        var speed: float = _rng.randf_range(70.0, 330.0) * power * speed_scale
        var life: float = _rng.randf_range(0.65, 1.55) * lerpf(0.8, 1.0, power)
        var color: Color = primary.lerp(secondary, _rng.randf_range(0.0, 1.0))
        _sparks.append({
            "pos": center,
            "vel": Vector2.from_angle(angle) * speed,
            "life": life,
            "max_life": life,
            "color": color,
            "width": _rng.randf_range(1.1, 2.8) * lerpf(0.8, 1.0, power),
        })

func _draw() -> void:
    for spark in _sparks:
        var energy: float = clampf(float(spark.life) / float(spark.max_life), 0.0, 1.0)
        var color: Color = spark.color
        var pos: Vector2 = spark.pos
        var tail: Vector2 = pos - spark.vel * TAIL_FACTOR
        var width: float = spark.width

        draw_circle(pos, width * 2.6, Color(color.r, color.g, color.b, 0.10 * energy))
        draw_line(tail, pos, Color(color.r, color.g, color.b, 0.35 * energy), width * 2.4, true)
        draw_line(tail, pos, Color(color.r, color.g, color.b, energy), width, true)
        draw_circle(pos, width * 0.9, Color(1.0, 1.0, 1.0, 0.85 * energy))

func _palette_for_rank(rank: int) -> Array[Color]:
    match rank:
        1:
            return [
                Color(0.98, 0.82, 0.35),
                Color(1.0, 0.92, 0.6),
                Color(1.0, 0.58, 0.12),
                Color(1.0, 1.0, 1.0),
            ]
        2:
            return [
                Color(0.78, 0.9, 1.0),
                Color(0.55, 0.74, 1.0),
                Color(1.0, 1.0, 1.0),
                Color(0.86, 0.9, 0.98),
            ]
        3:
            return [
                Color(1.0, 0.6, 0.28),
                Color(1.0, 0.79, 0.48),
                Color(0.92, 0.4, 0.18),
                Color(1.0, 0.93, 0.8),
            ]
    return [Color(1.0, 1.0, 1.0)]

func _gameplay_palette() -> Array[Color]:
    return [
        Color(0.45, 0.88, 0.8),
        Color(0.96, 0.8, 0.4),
        Color(1.0, 0.55, 0.42),
        Color(0.62, 0.7, 1.0),
    ]
