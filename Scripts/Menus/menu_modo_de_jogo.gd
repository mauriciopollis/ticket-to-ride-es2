extends Control


func _on_modo_solo_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu_dificuldade.tscn") # Replace with function body.


func _on_modo_player_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu_customizar.tscn")
	

func _on_botao_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
