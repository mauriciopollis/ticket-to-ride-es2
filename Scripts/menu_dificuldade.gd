extends Control


func _on_facil_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/tabuleiro.tscn") # Replace with function body.


func _on_medio_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/tabuleiro.tscn") # Replace with function body.


func _on_dificil_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/tabuleiro.tscn") # Replace with function body.


func _on_botao_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu_modo_de_jogo.tscn")
