extends Object

class_name BilheteDestino

var cidade1: Cidade
var cidade2: Cidade
var pontos: int

func _init(cidade1_: Cidade, cidade2_: Cidade, pontos_: int) -> void:
	self.cidade1 = cidade1_
	self.cidade2 = cidade2_
	self.pontos = pontos_
