extends Node

## Persistent highscore leaderboard, stored per level.
## Mirrors the ConfigFile usage of the Settings singleton.

const LEADERBOARD_FILE = "user://leaderboard.cfg"
const MAX_ENTRIES: int = 10

# Result of the most recent submitted run, used by the game over UI.
var last_level: String = ""
var last_score: int = 0
var last_rank: int = 0

var scores: Dictionary [String, Array] = {}

func _ready() -> void:
    load_scores()

## Adds a finished run to the level's leaderboard and returns its 1-based rank.
func add_score(level: String, score: int) -> int:
    var level_scores: Array = scores.get(level, [])
    level_scores.append(score)
    level_scores.sort()
    level_scores.reverse()
    if level_scores.size() > MAX_ENTRIES:
        level_scores.resize(MAX_ENTRIES)
    scores[level] = level_scores
    save_scores()

    last_level = level
    last_score = score
    last_rank = level_scores.find(score) + 1
    return last_rank

func get_scores(level: String) -> Array:
    return Array(scores.get(level, []))

func get_known_levels() -> Array[String]:
    var levels: Array[String] = []
    for level in scores.keys():
        levels.append(level)
    levels.sort()
    return levels

func save_scores() -> void:
    var config = ConfigFile.new()
    for level in scores:
        config.set_value("Scores", level, scores[level])
    config.save(LEADERBOARD_FILE)

func load_scores() -> void:
    scores.clear()
    var config = ConfigFile.new()
    if config.load(LEADERBOARD_FILE) != OK:
        return
    for level in config.get_section_keys("Scores"):
        scores[level] = Array(config.get_value("Scores", level, []))
