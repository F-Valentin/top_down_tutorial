extends Control

@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar


func update_health_bar(health: int) -> void:
	var tween: Tween = create_tween()

	tween.tween_property(texture_progress_bar, "value", health, 0.2)
