extends Node

var cenas : Dictionary = {"Menu_principal":"res://menuprincipal/menuprincipal.tscn",
						  "Level 1":"res://worlds/cena_inicial/quarto.tscn",
						  "Level 2": "res://worlds/tutorial.tscn"
}

func transition_to_scene(level : String):
	var scene_path : String = cenas.get(level)
	
	if scene_path != null:
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file(scene_path)
