extends Control


func _on_botao_jogar_pressed() -> void:
	get_tree().change_scene_to_file("res://tabuleiro.tscn")
