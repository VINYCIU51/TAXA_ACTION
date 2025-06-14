extends CanvasLayer

@onready var anim = $AnimationPlayer

func show_loading():
	visible = true
	await get_tree().create_timer(2.0).timeout
	
func hide_loading():
	visible = false
