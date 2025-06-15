extends CharacterBody2D

@onready var wall_collision: RayCast2D = $wall_collision

const SPEED := 300
const DAMAGE := 1

var direction := -1

# Define a direçao da bala
func set_direction(direct):
	direction = direct
	$sprite.flip_h = direction < 0

# Faz ela se mover
func _physics_process(_delta: float) -> void:
	velocity.x = SPEED * direction
	
	if wall_collision.is_colliding():
		await get_tree().create_timer(0.1).timeout
		queue_free()
	
	move_and_slide()
	
# Faz ela sumir ao sair da tela
func _on_visibility_screen_exited() -> void:
	queue_free()
