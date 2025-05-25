extends Object

class_name Rota

#const Cidade = preload("res://Scripts/Cidade.gd")
#const Jogador = preload("res://Scripts/Jogador.gd")

var id: int
var cidade1: Cidade
var cidade2: Cidade
var cor: String
var custo: int
var dono: Jogador = null

func _init(cidade1_: Cidade, cidade2_: Cidade, cor_: String, custo_: int):
	self.cidade1 = cidade1_
	self.cidade2 = cidade2_
	self.cor = cor_
	self.custo = custo_

func setDono(jogador: Jogador):
	self.dono = jogador
