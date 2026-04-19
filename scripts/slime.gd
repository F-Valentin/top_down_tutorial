extends CharacterBody2D


const SPEED: int = 100
const KNOCKBACK_FORCE: int = 100

var target = null
var health: int = 100
var is_alive: bool = true

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: Control = $HealthBar


func _physics_process(delta: float) -> void:
	if is_alive and target:
		_attack(delta)


func _attack(delta: float) -> void:
	var direction: Vector2 = (target.position - position).normalized()

	position += direction * SPEED * delta
	animated_sprite_2d.play("attack")


func take_damage(amount: int, attacker_position: Vector2) -> void:
	health -= amount

	if health <= 0:
		health_bar.update_health_bar(health)
		health_bar.hide()
		_die()
	else:
		var knockback_direction = (position - attacker_position).normalized()
		var target_position = position + knockback_direction * KNOCKBACK_FORCE

		var tween: Tween = create_tween()
		
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		health_bar.update_health_bar(health)
		tween.tween_property(self, "position", target_position, 0.5)


func _die() -> void:
	is_alive = false
	animated_sprite_2d.play("die")

	await animated_sprite_2d.animation_finished
	queue_free()


func _on_sight_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		target = body


func _on_sight_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		target = null
		animated_sprite_2d.play("idle")
