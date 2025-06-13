extends Control

func _on_intro_animation_finished(_anim_name: StringName):
	#get_tree().change_scene_to_file("res://menuprincipal/menuprincipal.tscn")
	GerenciadorDeCenas.transition_to_scene("Menu_principal")
