extends Control


func _on_jogar_pressed() -> void:
	pass # Replace with function body.
	get_tree().change_scene_to_file("res://worlds/cena_inicial/quarto.tscn")

func _on_sair_pressed() -> void:
	pass # Replace with function body.
	get_tree().quit()
