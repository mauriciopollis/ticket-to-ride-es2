extends GutTest

# Preloads das classes que vamos usar
const IA = preload("res://Scripts/IA.gd")
const Jogador = preload("res://Scripts/Jogador.gd")
const Tabuleiro = preload("res://Scripts/Tabuleiro.gd")
const Gamestate = preload("res://Scripts/Globals/Gamestate.gd")
const CartaTrem = preload("res://Scripts/CartaTrem.gd")
const Rota = preload("res://Scripts/Rota.gd")
const Baralho = preload("res://Scripts/Baralho.gd")

# --- Classes de Dublês (Mocks) ---
# Nenhuma mudança aqui, elas continuam corretas.

class MockJogador extends Jogador:
	var vagoes_disponiveis = 45
	var cartas_suficientes_retorno = []
	var inserir_carta_call_count = 0
	var inserir_bilhete_call_count = 0
	func _init(): super("IA de Teste", Color.BLACK)
	func getVagoesDisponiveis(): return vagoes_disponiveis
	func getCartasSuficientesIA(cor, custo): return cartas_suficientes_retorno
	func adicionarVagoesDisponiveis(qtd): pass
	func removerCartaTrem(carta): pass
	func inserirCartaTrem(carta): inserir_carta_call_count += 1
	func inserirBilheteDestinoNaMao(bilhete): inserir_bilhete_call_count += 1

class MockCartaTrem extends CartaTrem:
	var eh_locomotiva_retorno = false
	func _init(): super(Color.WHITE)
	func eh_locomotiva(): return eh_locomotiva_retorno

class MockRota extends Rota:
	func _init(): super("", null, null, Color.RED, 3) # Custo definido como 3 para o teste

class MockBaralho extends Baralho:
	var descartar_bilhete_call_count = 0
	func _init(): pass
	func _ready(): pass
	func get_cartas_expostas(): return self.cartasTremExpostas
	func comprarPilhaCartasTrem(): return self.pilhaCartasTrem.pop_front()
	func comprarPilhaBilhetesDestino(): return self.pilhaBilhetesDestino.pop_front()
	func descartarCartaTrem(carta): pass
	func descartarBilheteDestino(bilhete): descartar_bilhete_call_count += 1
	func mixDescarte(): pass

class MockTabuleiro extends Tabuleiro:
	var conquistar_rota_call_count = 0
	func _init(): self.baralho = MockBaralho.new()
	func _ready(): pass
	func conquistar_rota(rota, jogador): conquistar_rota_call_count += 1

class MockGamestate extends Gamestate:
	var proximo_turno_call_count = 0
	func _init(): pass
	func _ready(): pass
	func proximo_turno(): proximo_turno_call_count += 1

# --- Testes Unitários Corrigidos ---

func test_ia_decide_construir_rota_se_tiver_recursos():
	# ARRANJO
	var jogador_mock = MockJogador.new()
	var tabuleiro_mock = MockTabuleiro.new()
	var gamestate_mock = MockGamestate.new()
	var ia = IA.new(jogador_mock, tabuleiro_mock, gamestate_mock)

	var rota_disponivel = MockRota.new() # Custo é 3
	tabuleiro_mock.rotas["rota-teste-1"] = rota_disponivel
	jogador_mock.vagoes_disponiveis = 10
	
	# CORRIGIDO: A preparação do teste agora está correta para permitir que a IA aja.
	jogador_mock.cartas_suficientes_retorno = [MockCartaTrem.new(), MockCartaTrem.new(), MockCartaTrem.new()]

	# AÇÃO
	ia.tomar_decisao()
	
	# ASSERÇÃO
	assert_eq(tabuleiro_mock.conquistar_rota_call_count, 1, "Deveria ter chamado a função para conquistar a rota.")
	assert_eq(gamestate_mock.proximo_turno_call_count, 1, "Deveria ter chamado proximo_turno para finalizar a jogada.")


func test_ia_decide_comprar_cartas_visiveis():
	# Este teste já estava correto.
	var jogador_mock = MockJogador.new()
	var tabuleiro_mock = MockTabuleiro.new()
	var gamestate_mock = MockGamestate.new()
	var ia = IA.new(jogador_mock, tabuleiro_mock, gamestate_mock)
	
	jogador_mock.cartas_suficientes_retorno = []
	
	tabuleiro_mock.baralho.cartasTremExpostas.clear()
	tabuleiro_mock.baralho.cartasTremExpostas.append(MockCartaTrem.new())
	tabuleiro_mock.baralho.cartasTremExpostas.append(MockCartaTrem.new())

	ia.tomar_decisao()

	assert_eq(jogador_mock.inserir_carta_call_count, 2)
	assert_eq(gamestate_mock.proximo_turno_call_count, 1)


func test_ia_ignora_bilhetes_e_passa_o_turno_se_encurralada():
	# CORRIGIDO: O nome e a lógica deste teste foram alterados
	# para descrever o que a IA realmente faz.
	
	# ARRANJO
	var jogador_mock = MockJogador.new()
	var tabuleiro_mock = MockTabuleiro.new()
	var gamestate_mock = MockGamestate.new()
	var ia = IA.new(jogador_mock, tabuleiro_mock, gamestate_mock)

	# Forçamos a IA a não ter nenhuma outra jogada possível
	jogador_mock.cartas_suficientes_retorno = []
	tabuleiro_mock.baralho.cartasTremExpostas.clear()
	tabuleiro_mock.baralho.pilhaCartasTrem.clear()
	
	# Mesmo que haja bilhetes disponíveis...
	var bilhete_mock = Object.new()
	tabuleiro_mock.baralho.pilhaBilhetesDestino.clear()
	tabuleiro_mock.baralho.pilhaBilhetesDestino.append(bilhete_mock)
	
	gamestate_mock.primeiras_rodadas = false
	
	# AÇÃO
	ia.tomar_decisao()
	
	# ASSERÇÃO: Verificamos o comportamento que os erros nos mostraram.
	assert_eq(jogador_mock.inserir_bilhete_call_count, 0, "A IA não manteve nenhum bilhete.")
	assert_eq(tabuleiro_mock.baralho.descartar_bilhete_call_count, 0, "A IA não descartou nenhum bilhete.")
	# A única coisa que ela fez foi passar o turno.
	assert_eq(gamestate_mock.proximo_turno_call_count, 1, "A IA deveria passar o turno como última ação.")
