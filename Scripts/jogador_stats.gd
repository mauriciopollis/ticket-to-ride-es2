extends Control

var nome = "none"
var pontuacao_trilhos_contruidos: int = 0
var pontuacao_cartas_destino: int = 0
var bonus_maior_rota: int = 0
var pontuacao_total: int = 0
var tamanho_maior_rota: int = 0

func calcula_pontuacao_total():
	self.pontuacao_total = self.pontuacao_trilhos_contruidos + self.pontuacao_cartas_destino + self.bonus_maior_rota
	
