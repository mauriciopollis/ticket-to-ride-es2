extends Node

@onready var jogadores: Array[Jogador] = []
@onready var baralho = get_node("Baralho") as Baralho
#var jogadores: Dictionary = {} # armazenará referências a objetos da classe Jogador

var nomeJogadores: Array[String] = ['Ana', 'Beto', 'Carla'] # ordem no turno!
var corJogadores: Array[Color] = [Color.BLUE, Color.GREEN, Color.RED] # mesma ordem de jogadores

func _ready() -> void:
	print("Main rodando!!")

	iniciarJogo()

	printMaosJogadores()
	get_tree().change_scene_to_file("res://tabuleiro.tscn")


func iniciarJogo():
	criarJogadores(nomeJogadores, corJogadores)
	distribuirCartasEBilhetesIniciais()
	sortearOrdemInicial()


func distribuirCartasEBilhetesIniciais():
	for jogador in jogadores:
		baralho.darCartasTremJogador(jogador, 4)
		baralho.darBilhetesDestinoJogador(jogador, 3) # todos os jogadores recebem 3 bilhetes aleatórios, sem escolha

func criarJogadores(listaNomeJogadores: Array[String], listaCorJogadores: Array[Color]):
	for nome in listaNomeJogadores:
		var jogador = Jogador.new(nome, listaCorJogadores.pop_front())
		jogadores.append(jogador)

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

func sortearOrdemInicial():
	var ordens: Array = []
	for i in range(jogadores.size()):
		ordens.append(i)
	ordens.shuffle()
	
	for i in range(jogadores.size()):
		jogadores[i].ordemDeJogada = ordens[i]

func _on_botao_jogar_pressed():
	get_tree().change_scene_to_file("res://tabuleiro.tscn")
