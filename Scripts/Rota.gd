extends Object

class_name Rota

#const Cidade = preload("res://Scripts/Cidade.gd")
#const Jogador = preload("res://Scripts/Jogador.gd")

var nome: String
var cidade1: Cidade
var cidade2: Cidade
var cor: Color
var custo: int
var dono: Jogador = null

# chave: tamanho da rota
# valor: pontuação da rota
const PONTUACAO_ROTAS = {
	1: 1,
	2: 2,
	3: 4,
	4: 7,
	5: 10,
	6: 15
}

func _init(nome_: String, cidade1_: Cidade, cidade2_: Cidade, cor_: Color, custo_: int):
	self.nome = nome_
	self.cidade1 = cidade1_
	self.cidade2 = cidade2_
	self.cor = cor_
	self.custo = custo_

func setDono(jogador: Jogador):
	self.dono = jogador

static func getPontuacao(custo_rota: int):
	return PONTUACAO_ROTAS.get(custo_rota)
