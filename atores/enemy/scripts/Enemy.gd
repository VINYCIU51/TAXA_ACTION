extends CharacterBody2D

@onready var anim := $anim as AnimatedSprite2D
@onready var shoot_timer := $ShootTimer as Timer
@onready var player := get_node_or_null("/root/Main/Player") # ajuste conforme o caminho real
@onready var hurtbox := $HurtBox as Area2D

@export var speed := 80
@export var gravity := 800
@export var facing_left := true
@export var projectile_scene := preload("res://Scenes/Projectile.tscn") # precisa criar

var direction := -1 if facing_left else 1

func _ready():
	shoot_timer.start()

func _physics_process(delta):
	velocity.y += gravity * delta
	
	velocity.x = direction * speed
	move_and_slide()

	anim.play("walk")
	anim.flip_h = direction < 0

func _on_HurtBox_area_entered(area: Area2D):
	if area.get_parent().name == "Player": # alternativa: area.get_parent().is_in_group("player")
		area.get_parent().take_damage() # assume que player tem método take_damage()

func _on_ShootTimer_timeout():
	if not is_instance_valid(player):
		return
	
	var direction_to_player = (player.global_position - global_position).normalized()
	var bullet = projectile_scene.instantiate()
	bullet.position = global_position
	bullet.direction = direction_to_player
	get_tree().current_scene.add_child(bullet)
