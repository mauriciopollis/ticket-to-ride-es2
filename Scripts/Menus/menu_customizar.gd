extends Control

var maximo_jogadores: int = 5
var minimo_jogadores: int = 2
var qtd_players: int = maximo_jogadores
var qtd_ia: int = 0

@onready var play_button = $Panel/HBoxContainer/play
@onready var diminuir_player_button = $Panel/HBoxContainer/player/diminuir_qtd_player
@onready var aumentar_player_button = $Panel/HBoxContainer/player/aumentar_qtd_player
@onready var diminuir_ia_button = $Panel/HBoxContainer/ia/diminuir_qtd_ia
@onready var aumentar_ia_button = $Panel/HBoxContainer/ia/aumentar_qtd_ia
@onready var voltar_button = $Panel/botao_voltar

@onready var qtd_player_label = $Panel/HBoxContainer/player/qtd_player
@onready var qtd_ia_label = $Panel/HBoxContainer/ia/qtd_ia

func _ready():
	qtd_player_label.text = str(qtd_players)
	qtd_ia_label.text = str(qtd_ia)
	
	if play_button:
		play_button.connect("pressed", Callable(self, "_on_play_pressed"))

	if diminuir_player_button:
		diminuir_player_button.connect("pressed", Callable(self, "_on_diminuir_qtd_player_pressed"))

	if aumentar_player_button:
		aumentar_player_button.connect("pressed", Callable(self, "_on_aumentar_qtd_player_pressed"))

	if diminuir_ia_button:
		diminuir_ia_button.connect("pressed", Callable(self, "_on_diminuir_qtd_ia_pressed"))

	if aumentar_ia_button:
		aumentar_ia_button.connect("pressed", Callable(self, "_on_aumentar_qtd_ia_pressed"))

	if voltar_button:
		voltar_button.connect("pressed", Callable(self, "_on_botao_voltar_pressed"))

func _on_play_pressed() -> void:
	Gamestate.set_quantidades_jogadores(qtd_players, qtd_ia)
	get_tree().change_scene_to_file("res://Scenes/menu_setup_jogadores.tscn")

func _on_diminuir_qtd_player_pressed() -> void:
	if qtd_players > 0:
		if (qtd_players + qtd_ia <= minimo_jogadores) and (qtd_ia < maximo_jogadores):
			qtd_ia += 1
		qtd_players -= 1
	qtd_player_label.text = str(qtd_players)
	qtd_ia_label.text = str(qtd_ia)

func _on_aumentar_qtd_player_pressed() -> void:
	if qtd_players < maximo_jogadores:
		if (qtd_players + qtd_ia == maximo_jogadores) and (qtd_ia > 0):
			qtd_ia -= 1
		qtd_players += 1
	qtd_player_label.text = str(qtd_players)
	qtd_ia_label.text = str(qtd_ia)

func _on_diminuir_qtd_ia_pressed() -> void:
	if qtd_ia > 0:
		if (qtd_players + qtd_ia <= minimo_jogadores) and (qtd_players < maximo_jogadores):
			qtd_players += 1
		qtd_ia -= 1
	qtd_ia_label.text = str(qtd_ia)
	qtd_player_label.text = str(qtd_players)

func _on_aumentar_qtd_ia_pressed() -> void:
	if qtd_ia < maximo_jogadores:
		if (qtd_players + qtd_ia == maximo_jogadores) and (qtd_players > 0):
			qtd_players -= 1
		qtd_ia += 1
	qtd_ia_label.text = str(qtd_ia)
	qtd_player_label.text = str(qtd_players)

func _on_botao_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu_modo_de_jogo.tscn")
