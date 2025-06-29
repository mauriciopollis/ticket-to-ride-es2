# test_jogador_integracao.gd
extends GutTest

const Jogador = preload("res://Scripts/Jogador.gd")
const Rota = preload("res://Scripts/Rota.gd")
const Cidade = preload("res://Scripts/Cidade.gd")
const BilheteDestino = preload("res://Scripts/BilheteDestino.gd")
const CartaTrem = preload("res://Scripts/CartaTrem.gd")
const Baralho = preload("res://Scripts/Baralho.gd")

class BaralhoParaTestes extends Baralho:
	func _ready():
		pass 

	func descartarCartaTrem(carta: CartaTrem):
		descarteCartasTrem.append(carta)


func test_jogador_ganha_pontos_e_constroi_grafo_ao_receber_rota():
	var jogador = Jogador.new("Testador", Color.GREEN)
	var cidade_a = Cidade.new("A")
	var cidade_b = Cidade.new("B")
	var rota = Rota.new("A-B", cidade_a, cidade_b, Color.GREEN, 4)

	jogador.inserirRota(rota)

	assert_eq(jogador.pontos, 7)
	assert_eq(jogador.rotas.size(), 1)
	assert_true(jogador.grafo.has(cidade_a))
	assert_true(jogador.buscarCaminho(cidade_a, cidade_b))
	assert_eq(rota.dono, jogador)


func test_jogador_descarta_cartas_corretamente_para_pagar_rota():
	var jogador = Jogador.new("Gastador", Color.BLUE)
	var mock_baralho = BaralhoParaTestes.new()

	jogador.inserirCartaTrem(CartaTrem.new(Color.BLUE))
	jogador.inserirCartaTrem(CartaTrem.new(Color.BLUE))
	jogador.inserirCartaTrem(CartaTrem.new(Color.BLUE))
	jogador.inserirCartaTrem(CartaTrem.new(Color.TRANSPARENT))
	jogador.inserirCartaTrem(CartaTrem.new(Color.TRANSPARENT))
	
	var sucesso = jogador.removeNCores(4, Color.BLUE, mock_baralho)

	assert_true(sucesso)
	assert_eq(jogador.cartasTremNaMao.size(), 1)
	assert_eq(mock_baralho.descarteCartasTrem.size(), 4)
	
	var cores_descartadas = mock_baralho.descarteCartasTrem.map(func(carta): return carta.cor)
	var azuis_descartadas = cores_descartadas.count(Color.BLUE)
	var curingas_descartados = cores_descartadas.count(Color.TRANSPARENT)
	assert_eq(azuis_descartadas, 3)
	assert_eq(curingas_descartados, 1)


func test_jogador_valida_bilhete_completado_e_ganha_pontos():
	var jogador = Jogador.new("Viajante", Color.YELLOW)
	var cidade_a = Cidade.new("A")
	var cidade_b = Cidade.new("B")
	var cidade_c = Cidade.new("C")	
	
	jogador.inserirRota(Rota.new("A-B", cidade_a, cidade_b, Color.RED, 1))
	jogador.inserirRota(Rota.new("B-C", cidade_b, cidade_c, Color.RED, 1))
	var pontos_das_rotas = jogador.pontos
	
	var bilhete = BilheteDestino.new(cidade_a, cidade_c, 20, "")
	jogador.inserirBilheteDestinoNaMao(bilhete)

	jogador.validarBilheteDestinoNaMao(true)

	assert_eq(jogador.pontos, pontos_das_rotas + 20)
	assert_true(jogador.bilhetesDestinoNaMao.is_empty())
	assert_eq(jogador.bilhetesDestinoCompletados.size(), 1)


func test_jogador_valida_bilhete_incompleto_e_perde_pontos():
	var jogador = Jogador.new("Perdido", Color.BLACK)
	var cidade_a = Cidade.new("A")
	var cidade_b = Cidade.new("B")
	var cidade_c = Cidade.new("C")
	
	jogador.inserirRota(Rota.new("A-B", cidade_a, cidade_b, Color.RED, 1))
	var pontos_da_rota = jogador.pontos
	
	var bilhete_incompleto = BilheteDestino.new(cidade_a, cidade_c, 15, "")
	jogador.inserirBilheteDestinoNaMao(bilhete_incompleto)

	jogador.validarBilheteDestinoNaMao(true)

	assert_eq(jogador.pontos, pontos_da_rota - 15)
	assert_eq(jogador.bilhetesDestinoNaMao.size(), 1)
	assert_true(jogador.bilhetesDestinoCompletados.is_empty())
