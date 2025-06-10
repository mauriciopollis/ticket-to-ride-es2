extends Node

var qtd_players: int = 4
var jogadores: Array[Jogador] = []
var jogador_atual_idx: int = 0
var qtd_ia: int = 0

func jogador_atual():
	if jogadores.size() > 0:
		return jogadores[jogador_atual_idx]
	return null

func proximo_turno():
	if jogadores.size() == 0:
		return
	jogador_atual_idx = (jogador_atual_idx + 1) % jogadores.size()
	print("Agora é o turno do: ", jogador_atual().nome)


func inicializar_jogadores():
	jogadores.clear()
	var cores = [Color.RED, Color.BLUE, Color.GREEN, Color.YELLOW]
	for i in range(qtd_players):
		var nome = "Jogador %d" % (i + 1)
		var jogador = Jogador.new(nome, cores[i % cores.size()])
		jogadores.append(jogador)
	for i in range(qtd_ia):
		var nome = "IA %d" % (i + 1)
		var jogador = Jogador.new(nome, cores[(i + qtd_players) % cores.size()])
		jogadores.append(jogador)
	jogador_atual_idx = 0
