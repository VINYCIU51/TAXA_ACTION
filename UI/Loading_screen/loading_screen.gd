extends CanvasLayer

@onready var anim = $AnimationPlayer

func show_loading():
	visible = true
	print("mostrando loading")
	await get_tree().create_timer(2.0).timeout
	
func hide_loading():
	visible = false
	print("escondendo cena")
