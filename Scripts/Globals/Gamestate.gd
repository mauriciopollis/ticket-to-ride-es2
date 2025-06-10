extends Node

signal turno_trocado

var jogadores: Array[Jogador] = []
var jogador_atual_idx: int = 0

func jogador_atual():
	if jogadores.size() > 0:
		return jogadores[jogador_atual_idx]
	return null

func proximo_turno():
	if jogadores.size() == 0:
		return
	jogador_atual_idx = (jogador_atual_idx + 1) % jogadores.size()
	print("Agora é o turno do: ", jogador_atual().nome)
	emit_signal("turno_trocado")

func inicializar_jogadores(nomes_jogadores: Array, nomes_ias: Array) -> void:
	jogadores.clear()
	var cores = [Color.RED, Color.BLUE, Color.GREEN, Color.ORANGE, Color.PINK]
	cores.shuffle()
	var rng = RandomNumberGenerator.new()
	var todos_nomes = nomes_jogadores + nomes_ias
	for i in range(todos_nomes.size()):
		jogadores.append(Jogador.new(todos_nomes[i], cores[i]))
	jogador_atual_idx = rng.randi_range(0, jogadores.size() - 1)