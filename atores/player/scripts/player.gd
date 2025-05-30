extends CharacterBody2D

@onready var animation := $animation as AnimationPlayer

const SPEED := 250
const DEATH_HEIGHT := 1000
const DASH_SPEED := 1000
const DASH_DURATION := 0.15
const  INVENCIBLE_DURATION := 1.0

var life := 3

var direction
var dash_timer := 0.0
var invencible_timer := 0.0

var jump_height := 96
var time_to_top_height := 0.5
var jump_velocity
var gravity
var fall_gravity

var is_invencible := false
var is_dead := false
var taked_damage = false
var is_jumping = false
var is_dashing = false

func _ready():
	jump_velocity = (jump_height*2) / time_to_top_height
	gravity = (jump_height * 2) / pow(time_to_top_height,2)
	fall_gravity = gravity * 2

func _physics_process(delta):
	
	if global_position.y > DEATH_HEIGHT:
		fall_out()

	#if is_dead:
		#if animation.is_playing():
			#velocity.x = 0
		#return
		
	direction = Input.get_axis("move_left", "move_right")
	velocity.x = direction * SPEED

	if direction != 0:
		$sprite.flip_h = direction < 0

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_velocity
		animation.play("jump")
		is_jumping = true

	if not is_on_floor():
		if Input.is_action_pressed("jump") and velocity.y < 0:
			velocity.y += gravity * delta
		else:
			velocity.y += fall_gravity * delta
			
	if Input.is_action_just_pressed("dash") and direction != 0:
		animation.play("dash")
		is_dashing = true
		dash_timer = DASH_DURATION
		
	if is_dashing:
		velocity.x = direction * DASH_SPEED
		dash_timer -= delta
		is_invencible = true
		
		if dash_timer <= 0:
			is_dashing = false
			is_invencible = false

	if is_jumping:
		if not animation.is_playing() and is_on_floor():
			is_jumping = false
		move_and_slide()
		return
		
	if is_dashing:
		if not animation.is_playing():
			is_dashing = false
		move_and_slide()
		return
		
	if taked_damage:
		velocity.x = 0
		invencible_timer -= delta
		
		if invencible_timer <= 0:
			is_invencible = false
		
		#if not animation.is_playing():
			#taked_damage = false
		#move_and_slide()
		return

	if direction != 0:
		animation.play("run")
	#else:
		#animation.play("idle")

	move_and_slide()

func fall_out():
	get_tree().reload_current_scene()
	
func take_damage():
	
	if is_invencible:
		return
		
	taked_damage = true
	life -= 1
	
	if is_dead:
		return
	
	if life > 0:
		#animation.play("hurt")
		return
		
	#animation.play("die")
	is_dead = true
