extends Node

var cenas : Dictionary = {"Menu_principal":"res://UI/menu_principal/scenes/menuprincipal.tscn",
						  "Level 1":"res://worlds/cena_inicial/scenes/quarto.tscn",
						  "Level 2": "res://worlds/tutorial/scenes/tutorial.tscn"
}

func transition_to_scene(level : String):
	var scene_path :String = cenas.get(level)
	
	if scene_path != null:
		await LoadingScreen.show_loading()
		
		get_tree().change_scene_to_file(scene_path)

		await get_tree().process_frame

		await LoadingScreen.hide_loading()
