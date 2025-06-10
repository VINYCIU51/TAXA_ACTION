extends CharacterBody2D

@onready var animation := $animation as AnimationPlayer
@onready var invencible_timer := $invencible_timer
@onready var blink_timer := $blink_timer

const BULLET := preload("res://atores/player/projectiles/bullet.tscn")
const SPEED := 200
const DEATH_HEIGHT := 500
const DASH_SPEED := 700
const DASH_DURATION := 0.15

var life := 3
var is_dead := false

var dash_timer := 0.0
var jump_height := 96
var time_to_top_height := 0.5
var jump_velocity
var gravity
var fall_gravity

var direction = 0.0

var is_dashing = false
var is_invencible := false
var taked_damage := false
var is_shooting := false
var is_air_shooting := false
var current_state := "idle"

func _ready():
	jump_velocity = (jump_height * 2) / time_to_top_height
	gravity = (jump_height * 2) / pow(time_to_top_height, 2)
	fall_gravity = gravity * 2
	#add depois
	#if UpgradeManager.upgrades["dash_enabled"]:
		#enable_dash()
	#if UpgradeManager.upgrades["shoot_enabled"]:
		#enable_shoot()

#func enable_dash():
	#dash_active = true

#func enable_shoot():
	#shoot_active = true

func _physics_process(delta):
	if global_position.y > DEATH_HEIGHT:
		fall_out()

	if is_dead:
		velocity.x = 0
		set_state()
		return

	direction = Input.get_axis("move_left", "move_right")

	if !taked_damage:
		velocity.x = direction * SPEED

	if direction != 0 and !is_shooting and !is_air_shooting:
		rotate_player(direction)

	# Pulo
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_velocity

	# Gravidade
	if !is_on_floor():
		if Input.is_action_pressed("jump") and velocity.y < 0:
			velocity.y += gravity * delta
		else:
			velocity.y += fall_gravity * delta

	# Tiro no ar
	if !is_on_floor() and Input.is_action_just_pressed("right_click")and !is_air_shooting:
		is_air_shooting = true
		shoot(sign($bullet_point.position.x), 0.3)

	#adicionar dps
	#if shoot_active == true and Input.is_action_just_pressed("right_click"):
	
	# Tiro no chão
	if is_on_floor() and Input.is_action_just_pressed("right_click") and !is_shooting:
		is_shooting = true
		shoot(sign($bullet_point.position.x))
	
	#adicionar dps
	#if dash_active == true and Input.is_action_just_pressed("dash"):
		
	if Input.is_action_just_pressed("dash") and direction != 0:
		is_dashing = true
		dash_timer = DASH_DURATION
		
	if is_dashing:
		velocity.x = direction * DASH_SPEED
		dash_timer -= delta
		is_invencible = true
		
		if dash_timer <= 0:
			is_dashing = false
			is_invencible = false
		
	#if is_dashing:
		#if not animation.is_playing():
			#is_dashing = false
	
	# Verifica o fim do tiro
	if is_shooting:
		if !animation.is_playing(): is_shooting = false
	
	# Verufica o fim do tiro aereo
	if is_air_shooting:
		if !animation.is_playing(): is_air_shooting = false

	# Verifica fim de dano
	if taked_damage:
		knockback()
		if !animation.is_playing(): taked_damage = false

	move_and_slide()
	set_state()

func set_state():
	var new_state = "idle"

	#if is_dead:
		#new_state = "die"
	#elif taked_damage:
		#new_state = "hurt"
	#elif is_attacking:
		#new_state = "attack"
	#elif is_shooting:
		#new_state = "arrow"
	#elif is_air_shooting:
		#new_state = "air_arrow"
	#elif !is_on_floor():
		#new_state = "jump"
	#elif direction != 0:
		#new_state = "walk"

	if current_state != new_state:
		animation.play(new_state)
		current_state = new_state

func fall_out():
	get_tree().reload_current_scene()

func take_damage():
	if is_invencible or is_dead: return

	taked_damage = true
	invencible_mode()
	life -= 1

	if life <= 0: is_dead = true

func shoot(direct, time := 0.5):
	await get_tree().create_timer(time).timeout
	var bullet = BULLET.instantiate()
	add_sibling(bullet, true)
	bullet.set_direction(direct)
	bullet.position = $bullet_point.global_position

func rotate_player(direction):
	$sprite.flip_h = direction < 0
	if sign($bullet_point.position.x) != direction:
		$bullet_point.position.x *= -1

func knockback():
	var knock_direction = 1 if $sprite.flip_h else -1
	velocity.x = knock_direction * 100
		
func invencible_mode():
	is_invencible = true
	set_collision_mask_value(3,false)
	blink_timer.start()
	invencible_timer.start()

func _on_invencible_timer_timeout() -> void:
	is_invencible = false
	set_collision_mask_value(3,true)
	blink_timer.stop()
	$sprite.visible = true

func _on_blink_timer_timeout() -> void:
	$sprite.visible = !$sprite.visible
