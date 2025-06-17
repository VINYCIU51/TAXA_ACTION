extends Node2D

@onready var coleta = $coleta as AudioStreamPlayer

func _on_manopla_body_entered(body):
	if body.is_in_group("Player"):
		UpgradeManager.shoot_upgrated = true
		UpgradeManager.enable_gauntlet()

		# Remove coleta do nó atual para não ser destruído
		coleta.get_parent().remove_child(coleta)
		get_tree().current_scene.add_child(coleta)
		coleta.play()
		
		queue_free()

  		
