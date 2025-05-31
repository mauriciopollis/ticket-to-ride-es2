extends Control

@onready var qtd_players = 5
var setup_jogadores_scene

func _on_facil_pressed() -> void:
	setup_Jogadores()
	get_tree().root.add_child(setup_jogadores_scene)

func _on_medio_pressed() -> void:
	setup_Jogadores()
	get_tree().root.add_child(setup_jogadores_scene)

func _on_dificil_pressed() -> void:
	setup_Jogadores()
	get_tree().root.add_child(setup_jogadores_scene)

func _on_botao_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu_modo_de_jogo.tscn")
	
func setup_Jogadores() -> void:
	setup_jogadores_scene = preload("res://Scenes/menu_setup_jogadores.tscn").instantiate()
	setup_jogadores_scene.inicializar(5, 0)
