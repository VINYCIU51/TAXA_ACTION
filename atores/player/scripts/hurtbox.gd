extends Area2D

@export var player : CharacterBody2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		player.take_damage(1, body.global_position)
		
	if body.is_in_group("dangerous_bodys"):
		player.take_damage(1, body.global_position)
		body.queue_free()
