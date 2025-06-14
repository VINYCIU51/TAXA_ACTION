extends Node2D

func _on_manopla_body_entered(body):
	if body.is_in_group("Player"):
		UpgradeManager.enable_gauntlet()
		queue_free()
