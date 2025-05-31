extends Control

@onready var qtd_players = 5
@onready var tabuleiro_scene = preload("res://Scenes/tabuleiro.tscn").instantiate()

func _on_facil_pressed() -> void:
	setup_Jogadores()
	get_tree().root.add_child(tabuleiro_scene)

func _on_medio_pressed() -> void:
	setup_Jogadores()
	get_tree().root.add_child(tabuleiro_scene)

func _on_dificil_pressed() -> void:
	setup_Jogadores()
	get_tree().root.add_child(tabuleiro_scene)

func _on_botao_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu_modo_de_jogo.tscn")
	
func setup_Jogadores() -> void:
	var rng = RandomNumberGenerator.new()
	for i in range(qtd_players):
		tabuleiro_scene.jogadores.append(Jogador.new("Jogador " + str(i + 1), Color(rng.randf(), rng.randf(), rng.randf())))
