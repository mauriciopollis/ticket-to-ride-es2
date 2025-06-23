extends Object

class_name BilheteDestino

var cidade1: Cidade
var cidade2: Cidade
var pontos: int
var asset_path: String

func _init(cidade1_: Cidade, cidade2_: Cidade, pontos_: int, asset_path_: String) -> void:
	self.cidade1 = cidade1_
	self.cidade2 = cidade2_
	self.pontos = pontos_
	self.asset_path = asset_path_
