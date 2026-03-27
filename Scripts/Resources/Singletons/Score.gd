extends Node

var Score: int = 0
var ScoreCollector: int = 0

func add_points(points: int) -> void:
    Score += points

func add_points_to_collector(points: int) -> void:
    ScoreCollector += points

