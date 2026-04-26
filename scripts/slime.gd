extends CharacterBody2D


const SPEED: int = 100
const KNOCKBACK_FORCE: int = 100

var target = null
var target_in_range: bool = false
var health: int = 100
var is_alive: bool = true
var strength: int = 10

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: Control = $HealthBar
@onready var attack_timer: Timer = $AttackTimer


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


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		target_in_range = true
		body.take_damage(strength)
		attack_timer.start()


func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		target_in_range = false
		attack_timer.stop()


func _on_attack_timer_timeout() -> void:
	if target and target_in_range:
		target.take_damage(strength)
