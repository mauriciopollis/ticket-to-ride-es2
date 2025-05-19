extends Node

@onready var tabuleiro: Tabuleiro = $Tabuleiro
@onready var jogadores: Array[Jogador] = []
@onready var baralho = get_node("Baralho") as Baralho
#var jogadores: Dictionary = {} # armazenará referências a objetos da classe Jogador

var nomeJogadores: Array[String] = ['Ana', 'Beto', 'Carla'] # ordem no turno!
var corJogadores: Array[Color] = [Color.BLUE, Color.GREEN, Color.RED] # mesma ordem de jogadores

func _ready() -> void:
	print("Main rodando!!")

	iniciarJogo()

	printMaosJogadores()


func iniciarJogo():
	criarJogadores(nomeJogadores, corJogadores)
	distribuirCartasEBilhetesIniciais()


func distribuirCartasEBilhetesIniciais():
	for jogador in jogadores:
		baralho.darCartasTremJogador(jogador, 4)
		baralho.darBilhetesDestinoJogador(jogador, 3) # todos os jogadores recebem 3 bilhetes aleatórios, sem escolha

func criarJogadores(listaNomeJogadores: Array[String], listaCorJogadores: Array[Color]):
	for nome in listaNomeJogadores:
		var jogador = Jogador.new(nome, listaCorJogadores.pop_front())
		jogadores.append(jogador)

# prints de debug
func printCidades():
	print("Cidades carregadas: ")
	for nome in tabuleiro.cidades.keys():
		print("- ", nome)
func printRotas():
	print("Rotas carregadas: ")
	for rota in tabuleiro.rotas:
		print("%s -> %s (%d cartas, cor %s)" % [
			rota.cidade1.nome,
			rota.cidade2.nome,
			rota.custo,
			Utils.nomeCor(rota.cor)
		])
func printJogadores():
	print("Jogadores adicionados: ")
	for jog in jogadores:
		print("Nome: %s" % jog.nome)
		print("- Cor: %" % Utils.nomeCor(jog.cor))
		print("- Vagões disponíveis: %d" % jog.vagoesDisponiveis)
func printMaosJogadores():
	for jogador in jogadores:
		print("\n--- %s ---" % jogador.nome)
		print("Cartas de trem: %d" % jogador.cartasTremNaMao.size())
		for carta in jogador.cartasTremNaMao:
			print("- Cor: %s" % Utils.nomeCor(carta.cor))
		print("Bilhetes de destino: %d" % jogador.bilhetesDestinoNaMao.size())
		for bilhete in jogador.bilhetesDestinoNaMao:
			print("- De %s para %s (%d pontos)" % [bilhete.cidade1.nome, bilhete.cidade2.nome, bilhete.pontos])
