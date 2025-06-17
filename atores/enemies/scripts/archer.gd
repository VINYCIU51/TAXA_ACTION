class_name Archer
extends CharacterBody2D

# Referências automáticas a nós da cena
@onready var player = owner.get_node("player")
@onready var animation: AnimationPlayer = $body/animation
@onready var floor_edge: RayCast2D = $body/floor_edge
@onready var step_ahead: RayCast2D = $body/step_ahead
@onready var jump_clear: RayCast2D = $body/jump_clear
@onready var flexadoinimigo = $flexadoinimigo as AudioStreamPlayer # 🔊 Som da flecha
@onready var shoot_point = $body/shoot_point
@onready var sprite = $body/sprite

# Flecha instanciada
const PROJECTILE := preload("res://atores/enemies/scenes/arrow.tscn")

# Parâmetros do comportamento
const SPEED := 60
const JUMP_HEIGHT := -200
const DIST_FOLLOW := 350
const DIST_ATTACK := 200
const DAMAGE := 3

# Variáveis de estado
var distance := 0.0
var life := 6

var direction := 0
var horizontal_difference := 0
var is_exactly_below := 0
var is_below_player := 0
var at_edge := false
var at_wall := false
var should_jump := false

var is_dead := false
var is_damaged := false
var is_attacking := false
var is_following := false
var current_state := "idle"

# Controle de ataque por tempo
var can_attack := true

func _physics_process(delta: float) -> void:
	if !is_instance_valid(player): return
	
	# Detecta bordas, paredes e salto possível
	at_edge = !floor_edge.is_colliding()
	at_wall = step_ahead.is_colliding()
	should_jump = at_wall and !jump_clear.is_colliding()
	
	if is_dead:
		remove_from_group("enemies")
	
	if !is_on_floor():
		velocity += get_gravity() * delta
	
	if !is_dead:
		calculate_position()
		rotate_sprite()
	
	if is_exactly_below:
		velocity.x = 0
	
	# Segue o jogador se estiver próximo
	is_following = (
		distance <= DIST_FOLLOW and
		!is_exactly_below and
		!at_edge and
		!jump_clear.is_colliding() and
		!player.is_dead
	)

	# Pulo automático se necessário
	if is_following and should_jump:
		velocity.y = JUMP_HEIGHT
	
	# Movimento horizontal
	velocity.x = direction * SPEED if is_following else 0
	
	# Ataque se estiver próximo e puder atirar
	if distance <= DIST_ATTACK and !player.is_dead and can_attack:
		is_attacking = true
		velocity.x = 0
		can_attack = false
		attack_with_arrow()
		await get_tree().create_timer(1.2).timeout
		can_attack = true
		is_attacking = false
	
	# Se levou dano
	if is_damaged:
		velocity.x = 0
		if !animation.is_playing():
			is_damaged = false
	
	set_state()
	move_and_slide()

# Toca animação e som de ataque, e dispara a flecha
func attack_with_arrow():
	animation.play("shoot")
	flexadoinimigo.play() # 🔊 Som da flecha
	shoot()

# Define o estado atual e toca a animação
func set_state():
	var new_state = "idle"
	if is_dead:
		new_state = "die"
	elif is_attacking:
		new_state = "shoot"
	elif is_following:
		new_state = "walk"

	if current_state != new_state:
		animation.play(new_state)
		current_state = new_state

# Inverte a escala do sprite conforme o jogador
func rotate_sprite():
	direction = 1 if global_position.x < player.global_position.x else -1
	$body.scale.x = direction

# Recebe dano
func take_damage(damage: int):
	if is_dead or damage == 0: return
	hit_blink()
	is_damaged = true
	life -= damage
	if life <= 0:
		is_dead = true
		animation.play("die") # Toca animação de morte

# Instancia e dispara flecha
func shoot():
	var arrow = PROJECTILE.instantiate()
	add_sibling(arrow, true)
	var direct = sign($body.scale.x)
	arrow.set_direction(direct)
	arrow.position = shoot_point.global_position

# Calcula posição do jogador
func calculate_position():
	distance = global_position.distance_to(player.global_position)
	horizontal_difference = abs(global_position.x - player.global_position.x)
	is_below_player = global_position.y > player.global_position.y or global_position.y < player.global_position.y
	is_exactly_below = horizontal_difference < 2 and is_below_player

# Pisca ao levar dano
func hit_blink():
	sprite.self_modulate = Color(50, 50, 50, 1)
	await get_tree().create_timer(0.1).timeout
	sprite.self_modulate = Color(1, 1, 1, 1)

# Remove do jogo após animação de morte
func _on_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "die":
		queue_free()
