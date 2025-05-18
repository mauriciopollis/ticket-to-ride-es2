extends Object

class_name Jogador

#const Rota = preload("res://Scripts/Rota.gd")

var nome: String
var cor: Color
var vagoesDisponiveis: int = 45
var rotas: Array[Rota] = [] # grafo
var cartasTremNaMao: Array[CartaTrem] = []
var bilhetesDestinoNaMao: Array[BilheteDestino] = []

func _init(nome_: String, cor_: Color):
	self.nome = nome_
	self.cor = cor_

func inserirRota(rota: Rota):
	rotas.append(rota)

func resetarMao():
	cartasTremNaMao.clear()
	bilhetesDestinoNaMao.clear()

func inserirCartaTrem(carta: CartaTrem):
	cartasTremNaMao.append(carta)

func inserirBilheteDestino(bilhete: BilheteDestino):
	bilhetesDestinoNaMao.append(bilhete)
	
func removerCartaTrem(carta: CartaTrem):
	cartasTremNaMao.erase(carta)

func removerBilheteDestino(bilhete: BilheteDestino):
	bilhetesDestinoNaMao.erase(bilhete)
