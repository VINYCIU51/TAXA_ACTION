extends Area2D

@export var speed := 400
var direction := Vector2.ZERO

func initialize(dir: Vector2):
	direction = dir.normalized()

func _process(delta):
	position += direction * speed * delta

	# Remove se sair da tela
	if not get_viewport_rect().has_point(global_position):
		queue_free()

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage()
	queue_free()
