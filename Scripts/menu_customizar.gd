extends Control

var qtd_players: int = 4
var qtd_ia: int = 0
var maximo_adversarios: int = 4
var minimo_adversarios: int = 2

func _ready():
	$Panel/HBoxContainer/player/qtd_player.text = str(qtd_players)
	$Panel/HBoxContainer/ia/qtd_ia.text = str(qtd_ia)

func _on_play_pressed() -> void:
	Gamestate.qtd_players = qtd_players
	Gamestate.qtd_ia = qtd_ia
	get_tree().change_scene_to_file("res://Scenes/tabuleiro.tscn")

func _on_diminuir_qtd_player_pressed() -> void:
	if (qtd_players > 0):
		if (qtd_players + qtd_ia <= minimo_adversarios):
			qtd_ia += 1
		qtd_players -= 1
	$Panel/HBoxContainer/player/qtd_player.text = str(qtd_players)
	$Panel/HBoxContainer/ia/qtd_ia.text = str(qtd_ia)

func _on_aumentar_qtd_player_pressed() -> void:
	if (qtd_players < maximo_adversarios):
		if (qtd_players + qtd_ia == maximo_adversarios):
			qtd_ia -= 1
		qtd_players += 1
	$Panel/HBoxContainer/player/qtd_player.text = str(qtd_players)
	$Panel/HBoxContainer/ia/qtd_ia.text = str(qtd_ia)

func _on_diminuir_qtd_ia_pressed() -> void:
	if (qtd_ia > 0):
		if (qtd_players + qtd_ia <= minimo_adversarios):
			qtd_players += 1
		qtd_ia -= 1
	$Panel/HBoxContainer/ia/qtd_ia.text = str(qtd_ia)
	$Panel/HBoxContainer/player/qtd_player.text = str(qtd_players)

func _on_aumentar_qtd_ia_pressed() -> void:
	if (qtd_ia < maximo_adversarios):
		if (qtd_players + qtd_ia == maximo_adversarios):
			qtd_players -= 1
		qtd_ia += 1
	$Panel/HBoxContainer/ia/qtd_ia.text = str(qtd_ia)
	$Panel/HBoxContainer/player/qtd_player.text = str(qtd_players)
