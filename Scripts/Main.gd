extends Node

@onready var tabuleiro: Tabuleiro = $Tabuleiro

var jogadores: Dictionary = {} # armazenará referências a objetos da classe Jogador

func _ready() -> void:
	print("Main rodando!!")
	
	print("Cidades carregadas: ")
	for nome in tabuleiro.cidades.keys():
		print("- ", nome)
		
	print("Rotas carregadas: ")
	for rota in tabuleiro.rotas:
		print("%s -> %s (%d cartas, cor %s)" % [
			rota.cidade1.nome,
			rota.cidade2.nome,
			rota.custo,
			rota.cor
		])
