extends Node

signal turno_trocado
signal forcar_compra_bilhete
signal ultima_rodada_iniciada

var cena_fim = preload("res://Scenes/fim.tscn")

var qtd_players = 0
var qtd_ia = 0
var isModoSolo = false

var jogadores: Array[Jogador] = []
var jogador_atual_idx: int = 0

var ias_no_jogo: Dictionary = {}

var primeiras_rodadas = true
var inicio_do_fim = false
var fim = false
var ultimo_a_jogar: int = -1
var turno = 0

func jogador_atual() -> Jogador:
	if jogadores.size() > 0:
		return jogadores[jogador_atual_idx]
	return null

func jogadores_restantes() -> Array[Jogador]:
	if jogadores.size() > 1:
		return jogadores.slice(0, jogador_atual_idx) + jogadores.slice(jogador_atual_idx + 1, jogadores.size())
	return []


func set_quantidades_jogadores(num_humanos: int, num_ias: int) -> void:
	self.qtd_players = num_humanos
	self.qtd_ia = num_ias

func proximo_turno():
	if jogador_atual():
		jogador_atual().fezAcaoPrincipal = false
		jogador_atual().cartasCompradasNesteTurno = 0
		jogador_atual().comprouLocomotivaVisivel = false

	turno += 1

	if turno == jogadores.size():
		primeiras_rodadas = false

	if inicio_do_fim and ultimo_a_jogar == jogador_atual_idx:
		fim = true
		get_tree().change_scene_to_packed(cena_fim)
		return

	if jogadores.size() > 0 and jogador_atual().vagoesDisponiveis <= 2 and not inicio_do_fim:
		inicio_do_fim = true
		ultimo_a_jogar = jogador_atual_idx
		print("INICIANDO ÚLTIMA RODADA! Jogador: ", jogador_atual().nome, " com ", jogador_atual().vagoesDisponiveis, " vagões")
		emit_signal("ultima_rodada_iniciada")
	
	if jogadores.size() == 0:
		push_warning("Nenhum jogador para avançar o turno.")
		return

	jogador_atual_idx = (jogador_atual_idx + 1) % jogadores.size()
	
	print("Turno de: ", jogador_atual().nome, " (Cor: ", Utils.nomeCor(jogador_atual().cor), ") ---")
	
	emit_signal("turno_trocado")

	if ias_no_jogo.has(jogador_atual()):
		var ia_controller = ias_no_jogo[jogador_atual()]
		ia_controller.tomar_decisao()
	else:
		if primeiras_rodadas:
			emit_signal("forcar_compra_bilhete")

func inicializar_jogadores(nomes_jogadores: Array, nomes_ias: Array) -> void:
	jogadores.clear()
	ias_no_jogo.clear()
	
	var cores = [Color.RED, Color.BLUE, Color.GREEN, Color.ORANGE, Color.PINK]
	cores.shuffle()
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var todos_nomes = nomes_jogadores + nomes_ias
	
	for i in range(todos_nomes.size()):
		var novo_jogador = Jogador.new(todos_nomes[i], cores[i])
		if nomes_ias.has(todos_nomes[i]):
			novo_jogador.is_ia = true
		jogadores.append(novo_jogador)
	jogador_atual_idx = rng.randi_range(0, jogadores.size() - 1)
	print("Jogo começou. Primeiro jogador: ", jogador_atual().nome)


func distribuir_cartas(baralho: Baralho):
	for i in range(4):
		for jogador in jogadores:
			var carta = baralho.comprarPilhaCartasTrem()
			if carta:
				jogador.inserirCartaTrem(carta)
			else:
				push_warning("Não há mais cartas de trem para distribuir no início do jogo.")
				break
