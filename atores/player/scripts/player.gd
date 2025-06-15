class_name Player
extends CharacterBody2D

@onready var animation: AnimationPlayer = $body/animation
@onready var invincible_timer := $invincible_timer
@onready var blink_timer := $blink_timer
@onready var dash_cooldown: Timer = $dash_cooldown

const BULLET := preload("res://atores/player/projectiles/bullet.tscn")
const SPEED := 150
const DEATH_HEIGHT := 500
const DASH_SPEED := 500
const DASH_DURATION := 0.15

var life := 3
var is_dead := false

var dash_timer := 0.0
var jump_height := 90
var time_to_top_height := 0.5
var jump_velocity
var gravity
var fall_gravity

var direction = 0.0

var can_dash := true
var is_dashing := false
var is_invincible := false
var is_damaged := false
var is_shooting := false
var current_state := "idle"

func _ready():
	jump_velocity = (jump_height * 2) / time_to_top_height
	gravity = (jump_height * 2) / pow(time_to_top_height, 2)
	fall_gravity = gravity * 2

func _physics_process(delta):
	# Variáveis que desbloqueiam com base nos upgrades coletados
	var dash_active := UpgradeManager.dash_upgrated
	var shoot_active := UpgradeManager.shoot_upgrated

	if global_position.y > DEATH_HEIGHT:
		fall_off_screen()

	# Verifica a morte para nao realizar mais movimentos
	if is_dead:
		velocity.x = 0
		velocity.y += fall_gravity * delta
		move_and_slide()
		set_state()
		return

	# Define a direcao com base no input
	direction = Input.get_axis("move_left", "move_right")

	if !is_damaged:
		velocity.x = direction * SPEED

	# rotaciona o sprite com base na direcao
	if direction != 0 and !is_shooting:
		flip_sprite(direction)

	# pulo
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_velocity

	# diferentes gravidades com base no tempo de pressao do pulo
	if !is_on_floor():
		if Input.is_action_pressed("jump") and velocity.y < 0:
			velocity.y += gravity * delta
		else:
			velocity.y += fall_gravity * delta

	# tiro
	if Input.is_action_just_pressed("right_click") and !is_shooting and shoot_active:
		is_shooting = true

	# dash
	if Input.is_action_just_pressed("dash") and direction != 0 and can_dash and dash_active:
		is_dashing = true
		dash_timer = DASH_DURATION

	# validacoes de controle
	if is_dashing:
		dash()
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			is_invincible = false

	if is_shooting and !animation.is_playing():
		is_shooting = false

	if is_damaged and !animation.is_playing():
		is_damaged = false

	set_state()
	move_and_slide()

# executa o dash
func dash():
	velocity.x = direction * DASH_SPEED
	can_dash = false
	is_invincible = true
	dash_cooldown.start()

# muda a animacao
func set_state():
	var new_state = "idle"
	
	if is_dead:
		new_state = "die"
	elif is_shooting:
		new_state = "shoot"
	elif is_damaged:
		new_state = "hurt"
		
	if current_state != new_state:
		animation.play(new_state)
		current_state = new_state

# Faz ele reaparecer ao cair dos limites da tela
func fall_off_screen():
	get_tree().reload_current_scene()

# Efetua as verificações e ativações ao tomar um hit
func take_damage(damage: int, enemie_position := Vector2.ZERO):
	if is_invincible or is_dead:
		return

	is_damaged = true
	knockback(enemie_position)
	enable_invincibility()
	life -= damage

	if life <= 0:
		is_dead = true

# Efetua o disparo
func shoot():
	var bullet = BULLET.instantiate()
	add_sibling(bullet, true)
	var direct = sign($body.scale.x)
	bullet.set_direction(direct)
	bullet.position = $body/bullet_point.global_position

# Inverte a direção do sprite do personagem
func flip_sprite(dir):
	$body.scale.x = sign(dir)

# Faz o personagem ser lançado na direção oposta do inimigo que lhe feriu
func knockback(dir):
	var knock_direction = sign(global_position.x - dir.x)
	velocity.x = knock_direction * 100

# Ativa o modo de invencibilidade permitindo o personagem andar sem tomar dano por um período
func enable_invincibility():
	is_invincible = true
	set_collision_mask_value(3, false)
	blink_timer.start()
	invincible_timer.start()

func _on_invincible_timer_timeout() -> void:
	is_invincible = false
	set_collision_mask_value(3, true)
	blink_timer.stop()
	$body/sprite.visible = true

func _on_blink_timer_timeout() -> void:
	$body/sprite.visible = !$body/sprite.visible

func _on_dash_cooldown_timeout() -> void:
	can_dash = true
