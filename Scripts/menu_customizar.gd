extends Control

var maximo_jogadores: int = 5
var minimo_jogadores: int = 2
var qtd_players: int = maximo_jogadores
var qtd_ia: int = 0

func _ready():
	$Panel/HBoxContainer/player/qtd_player.text = str(qtd_players)
	$Panel/HBoxContainer/ia/qtd_ia.text = str(qtd_ia)

func _on_play_pressed() -> void:
	var rng = RandomNumberGenerator.new()
	var tabuleiro_scene = preload("res://Scenes/tabuleiro.tscn").instantiate()
	for i in range(qtd_ia):
		tabuleiro_scene.jogadoresIA.append(Jogador.new("IA " + str(i + 1), Color(rng.randf(), rng.randf(), rng.randf())))
	for i in range(qtd_players):
		tabuleiro_scene.jogadoresReais.append(Jogador.new("Jogador " + str(i + 1), Color(rng.randf(), rng.randf(), rng.randf())))
	get_tree().root.add_child(tabuleiro_scene)

func _on_diminuir_qtd_player_pressed() -> void:
	if(qtd_players > 0):
		if(qtd_players + qtd_ia <= minimo_jogadores):
			qtd_ia += 1
		qtd_players -= 1
	$Panel/HBoxContainer/player/qtd_player.text = str(qtd_players)
	$Panel/HBoxContainer/ia/qtd_ia.text = str(qtd_ia)

func _on_aumentar_qtd_player_pressed() -> void:
	if(qtd_players < maximo_jogadores):
		if(qtd_players + qtd_ia == maximo_jogadores):
			qtd_ia -= 1
		qtd_players += 1
	$Panel/HBoxContainer/player/qtd_player.text = str(qtd_players)
	$Panel/HBoxContainer/ia/qtd_ia.text = str(qtd_ia)

func _on_diminuir_qtd_ia_pressed() -> void:
	if(qtd_ia > 0):
		if(qtd_players + qtd_ia <= minimo_jogadores):
			qtd_players += 1
		qtd_ia -= 1
	$Panel/HBoxContainer/ia/qtd_ia.text = str(qtd_ia)
	$Panel/HBoxContainer/player/qtd_player.text = str(qtd_players)

func _on_aumentar_qtd_ia_pressed() -> void:
	if(qtd_ia < maximo_jogadores):
		if(qtd_players + qtd_ia == maximo_jogadores):
			qtd_players -= 1
		qtd_ia += 1
	$Panel/HBoxContainer/ia/qtd_ia.text = str(qtd_ia)
	$Panel/HBoxContainer/player/qtd_player.text = str(qtd_players)


func _on_botao_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu_modo_de_jogo.tscn")
