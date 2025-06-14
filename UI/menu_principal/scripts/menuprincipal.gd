extends Control


func _on_jogar_pressed() -> void:
	pass # Replace with function body.
	GerenciadorDeCenas.transition_to_scene("Level 2")

func _on_sair_pressed() -> void:
	pass # Replace with function body.
	get_tree().quit()
