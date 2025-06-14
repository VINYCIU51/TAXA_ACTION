extends Control

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)  # Garante que o mouse esteja visível no menu pause

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):  # Por padrão, "ui_cancel" é mapeado para Esc
		if get_tree().paused:
			resume()
		else:
			pause()

func pause() -> void:
	get_tree().paused = true
	visible = true  # Exibe o menu de pausa

func resume() -> void:
	get_tree().paused = false
	visible = false  # Oculta o menu de pausa

func _on_pausa_1_pressed() -> void:
	resume()

func _on_sair_2_pressed() -> void:
	get_tree().quit()
