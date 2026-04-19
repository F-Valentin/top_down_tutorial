extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var last_direction: Vector2 = Vector2.ZERO
var is_attacking: bool = false
var hitbox_offset: Vector2
var strength: int = 20

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var swing_sord_sound: AudioStreamPlayer2D = $SwingSwordSound
@onready var hitbox: Area2D = $HitBox


func _ready() -> void:
	hitbox.monitoring = false
	hitbox_offset = hitbox.position


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack(last_direction)

	if is_attacking:
		velocity = Vector2.ZERO
		return 
	
	hitbox.monitoring = false
	process_movement()
	process_animation()
	move_and_slide()


func process_movement() -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("left", "right", "up", "down")
	
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_direction = direction
		update_hitbox_offset()
	else:
		velocity = Vector2.ZERO


func process_animation() -> void:
	if is_attacking:
		return 
	if velocity != Vector2.ZERO:
		play_animation("run", last_direction)
	else:
		play_animation("idle", last_direction)


func play_animation(prefix: String, direction: Vector2) -> void:
	if direction.x != 0:
		animated_sprite_2d.flip_h = direction.x < 0
		animated_sprite_2d.play(prefix + "_right")             
	elif direction.y > 0:
		animated_sprite_2d.play(prefix + "_down")
	elif direction.y < 0:
		animated_sprite_2d.play(prefix + "_up")


func attack(direction: Vector2) -> void:
	is_attacking = true
	swing_sord_sound.play()
	hitbox.monitoring = true
	play_animation("attack", direction)


func _on_animated_sprite_2d_animation_finished() -> void:
	if is_attacking:
		is_attacking = false


func update_hitbox_offset() -> void:
	var x: float = hitbox_offset.x
	var y: float = hitbox_offset.y

	match last_direction:
		Vector2.LEFT:
			hitbox.position = Vector2(-x, y)
		Vector2.RIGHT:
			hitbox.position = Vector2(x, y)
		Vector2.UP:
			hitbox.position = Vector2(y, -x)
		Vector2.DOWN:
			hitbox.position = Vector2(-y, x)


func _on_hit_box_body_entered(body: Node2D) -> void:
	if is_attacking and body.name.begins_with("Slime"):
		body.take_damage(strength, position)
