class_name FastShooter
extends CharacterBody2D

# ——— Referências da cena
@onready var player = owner.get_node("player")
@onready var animation: AnimationPlayer = $body/animation
@onready var floor_edge: RayCast2D = $body/floor_edge
@onready var step_ahead: RayCast2D = $body/step_ahead
@onready var jump_clear: RayCast2D = $body/jump_clear
@onready var sfx_arrow: AudioStreamPlayer = $flexadoinimigo
@onready var shoot_point: Node2D = $body/shoot_point
@onready var sprite: Sprite2D = $body/sprite

# ——— Flecha instanciada
const PROJECTILE = preload("res://atores/enemies/scenes/arrow.tscn")

# ——— Parâmetros de comportamento
const SPEED := 160
const JUMP_FORCE := -250
const DIST_FOLLOW := 500
const DIST_ATTACK := 300
const DAMAGE := 3
const ATTACK_COOLDOWN := 0.8

# ——— Estado do inimigo
var life := 6
var is_dead := false
var is_damaged := false
var is_attacking := false
var can_attack := true
var current_state := "idle"

# ——— Detecção e movimentação
var direction := 1
var distance := 0.0
var should_jump := false

# ———————————————————————————————
# PROCESSO PRINCIPAL
# ———————————————————————————————
func _physics_process(delta: float) -> void:
	if !is_instance_valid(player): return

	if is_dead:
		remove_from_group("enemies")
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Gravidade
	if !is_on_floor():
		velocity.y += get_gravity().y * delta

	calculate_position()
	control_movement()
	control_attack()
	handle_damage()
	set_state()
	move_and_slide()

# ———————————————————————————————
# MOVIMENTO
# ———————————————————————————————
func control_movement():
	if distance <= DIST_FOLLOW:
		direction = sign(player.global_position.x - global_position.x)
		rotate_sprite()

		if step_ahead.is_colliding() and !jump_clear.is_colliding():
			should_jump = true
		else:
			should_jump = false

		if should_jump:
			velocity.y = JUMP_FORCE

		velocity.x = direction * SPEED
	else:
		velocity.x = 0

func rotate_sprite():
	sprite.scale.x = direction

# ———————————————————————————————
# ATAQUE
# ———————————————————————————————
func control_attack():
	if distance <= DIST_ATTACK and can_attack and !player.is_dead:
		is_attacking = true
		velocity.x = 0
		attack_with_arrow()
		await get_tree().create_timer(ATTACK_COOLDOWN).timeout
		can_attack = true
		is_attacking = false

func attack_with_arrow():
	can_attack = false
	animation.play("shoot")
	sfx_arrow.play()
	shoot_toward_player()

func shoot_toward_player():
	var arrow = PROJECTILE.instantiate()
	add_sibling(arrow, true)

	var dir_vector = (player.global_position - shoot_point.global_position).normalized()
	arrow.position = shoot_point.global_position

	if arrow.has_method("set_velocity"):
		arrow.set_velocity(dir_vector * 400)

# ———————————————————————————————
# DANO E MORTE
# ———————————————————————————————
func take_damage(amount: int):
	if is_dead or amount <= 0: return

	life -= amount
	hit_blink()
	is_damaged = true

	if life <= 0:
		is_dead = true
		animation.play("die")

func hit_blink():
	sprite.self_modulate = Color(2, 0.2, 0.2)
	await get_tree().create_timer(0.1).timeout
	sprite.self_modulate = Color(1, 1, 1)

# ———————————————————————————————
# ESTADO & ANIMAÇÕES
# ———————————————————————————————
func calculate_position():
	distance = global_position.distance_to(player.global_position)

func set_state():
	var new_state = "idle"

	if is_dead:
		new_state = "die"
	elif is_attacking:
		new_state = "shoot"
	elif velocity.length() > 10:
		new_state = "walk"

	if current_state != new_state:
		animation.play(new_state)
		current_state = new_state

func handle_damage():
	if is_damaged:
		velocity.x = 0
		if !animation.is_playing():
			is_damaged = false

func _on_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "die":
		queue_free()
