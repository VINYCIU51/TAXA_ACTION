extends CharacterBody2D

const SPEED := 300
const DAMAGE := 1

var direction := 1

# Define a direçao da flecha
func set_direction(direct):
	direction = direct
	$sprite.flip_h = direction < 0

# Faz ela se mover
func _physics_process(_delta: float) -> void:
	velocity.x = SPEED * direction
	move_and_slide()
	
# Faz ela sumir ao sair da tela
func _on_visibility_screen_exited() -> void:
	queue_free()
