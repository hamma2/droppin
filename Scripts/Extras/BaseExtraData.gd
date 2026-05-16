class_name ExtraData extends Resource

## Datenklasse für spawnable Extra Items

## Das Script des Items, das die Effektanwendung steuert
@export var effect_script: Script = null

## Die Stärke/Dauer des Effekts
@export var effect_strength: float = 1.0

## Die Farbe des Items für visuelle Unterscheidung
@export var color: Color = Color.WHITE

## Das Icon/Sprite für das Item
@export var texture: Texture2D

## Die Größe des Items
@export var scale_factor: float = 1.0

## Wahrscheinlichkeit, dass dieses Extra spawnt (0.0 bis 1.0)
@export var spawn_probability: float = 0.3

## Zusätzliche Dauer für zeitbasierte Effekte
@export var duration: float = 1.0

# Rotation des Extras wird geändert beim Treffen der Wand
@export var rotation_change: float = 0.0

# Animation called after collection
@export var collect_animation: Animation = null

@export var is_collectible: bool = false

func _init(p_effect_strength: float = 1.0, 
           p_color: Color = Color.WHITE, p_texture: Texture2D = null, 
           p_scale: float = 1.0, p_probability: float = 0.3, p_duration: float = 1.0,
           p_rotation_change: float = 0.0, p_collected_animation: Animation = null,
           p_is_collectible: bool = false) -> void:
    effect_strength = p_effect_strength
    color = p_color
    texture = p_texture
    scale_factor = p_scale
    spawn_probability = p_probability
    duration = p_duration
    rotation_change = p_rotation_change
    collect_animation = p_collected_animation
    is_collectible = p_is_collectible
