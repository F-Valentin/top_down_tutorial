extends Node2D

var level: int = 1
var current_level_root: Node = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_level_root = get_node_or_null("LevelRoot")
	_load_level(level)

	


func _load_level(level_number: int) -> void:
	if current_level_root:
		current_level_root.queue_free()
	
	var level_path: String = "res://scenes/levels/level_%s.tscn" % level_number

	current_level_root = load(level_path).instantiate()
	add_child(current_level_root)
	current_level_root.name = "LevelRoot"
	_setup_level(current_level_root)


func _setup_level(level_root: Node) -> void:
	var player = level_root.get_node("Player")

	player.died.connect(_on_player_died)
	var exit: Area2D = level_root.get_node_or_null("Exit")

	if exit:
		exit.body_entered.connect(_on_exit_body_entered)



func _on_exit_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		level += 1
		call_deferred("_load_level", level)

func _on_player_died() -> void:
	level = 1
	PlayerStats.reset()
	_load_level(level)