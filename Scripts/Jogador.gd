extends Object

class_name Jogador

#const Rota = preload("res://Scripts/Rota.gd")

var id: int
var nome: String
var cor: Color
var rotas: Array[Rota] = []

func _init(id_: int, nome_: String, cor_: Color):
	self.id = id_
	self.nome = nome_
	self.cor = cor_

func insereRota(rota: Rota):
	rotas.append(rota)
