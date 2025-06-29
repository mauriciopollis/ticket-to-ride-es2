extends GutTest

const Baralho = preload("res://Scripts/Baralho.gd")
const Jogador = preload("res://Scripts/Jogador.gd")
const Cidade = preload("res://Scripts/Cidade.gd")
const CartaTrem = preload("res://Scripts/CartaTrem.gd")
const BilheteDestino = preload("res://Scripts/BilheteDestino.gd")
const Tabuleiro = preload("res://Scripts/Tabuleiro.gd")


class TabuleiroParaTestes extends Tabuleiro:
	func _init():
		self.TabuleiroData = { "CIDADES": [], "ROTAS": [], "COR_DICT": {} }
		
		var nomes_cidades = [
			"Los Angeles", "New York", "Duluth", "Houston", "Sault St Marie", 
			"Nashville", "Atlanta", "Portland", "Vancouver", "Montreal", "El Paso", 
			"Toronto", "Miami", "Phoenix", "Dallas", "Calgary", "Salt Lake City", 
			"Winnipeg", "Little Rock", "San Francisco", "Kansas City", "Chicago", 
			"Santa Fe", "Boston", "New Orleans", "Seattle", "Denver", "Pittsburgh", "Helena"
		]
		for nome in nomes_cidades:
			if not cidades.has(nome):
				cidades[nome] = Cidade.new(nome)

	func _ready():
		pass 


var baralho: Baralho
var tabuleiro_mock: TabuleiroParaTestes

func before_each():
	tabuleiro_mock = TabuleiroParaTestes.new()
	baralho = Baralho.new()
	tabuleiro_mock.add_child(baralho)
	add_child_autofree(tabuleiro_mock)

func test_montagem_inicial_das_pilhas():
	assert_eq(baralho.pilhaCartasTrem.size(), 110, "A pilha de cartas de trem deveria começar com 110 cartas.")
	assert_eq(baralho.pilhaBilhetesDestino.size(), 30, "A pilha de bilhetes de destino deveria começar com 30 bilhetes.")
	assert_eq(baralho.descarteCartasTrem.size(), 0, "O descarte de cartas de trem deveria começar vazio.")

func test_comprar_carta_trem_diminui_pilha():
	var tamanho_inicial = baralho.pilhaCartasTrem.size()
	var carta = baralho.comprarPilhaCartasTrem()
	assert_is(carta, CartaTrem, "Deveria retornar um objeto CartaTrem.")
	assert_eq(baralho.pilhaCartasTrem.size(), tamanho_inicial - 1, "A pilha de cartas de trem deveria ter uma carta a menos.")

func test_comprar_bilhete_destino_diminui_pilha():
	var tamanho_inicial = baralho.pilhaBilhetesDestino.size()
	var bilhete = baralho.comprarPilhaBilhetesDestino()
	assert_is(bilhete, BilheteDestino, "Deveria retornar um objeto BilheteDestino.")
	assert_eq(baralho.pilhaBilhetesDestino.size(), tamanho_inicial - 1, "A pilha de bilhetes deveria ter um bilhete a menos.")

func test_descartar_carta_aumenta_descarte():
	var carta_para_descarte = CartaTrem.new(Color.RED)
	baralho.descartarCartaTrem(carta_para_descarte)
	assert_eq(baralho.descarteCartasTrem.size(), 1, "A pilha de descarte deveria ter 1 carta.")
	assert_eq(baralho.descarteCartasTrem[0], carta_para_descarte, "A carta na pilha de descarte é a carta que foi descartada.")

func test_remontar_pilha_cartas_trem_quando_vazia():
	baralho.pilhaCartasTrem.clear()
	baralho.descarteCartasTrem.append(CartaTrem.new(Color.BLUE))
	baralho.descarteCartasTrem.append(CartaTrem.new(Color.GREEN))
	var carta_comprada = baralho.comprarPilhaCartasTrem()
	assert_not_null(carta_comprada, "Deveria ter conseguido comprar uma carta.")
	assert_eq(baralho.pilhaCartasTrem.size(), 1, "A pilha deveria ser remontada e ter 1 carta sobrando.")
	assert_eq(baralho.descarteCartasTrem.size(), 0, "A pilha de descarte deveria ficar vazia.")

func test_dar_cartas_a_um_jogador():
	var jogador = Jogador.new("Teste", Color.PURPLE)
	var cartas_no_baralho_antes = baralho.pilhaCartasTrem.size()
	baralho.darCartasTremJogador(jogador, 4)
	assert_eq(jogador.cartasTremNaMao.size(), 4, "O jogador deveria ter 4 cartas na mão.")
	assert_eq(baralho.pilhaCartasTrem.size(), cartas_no_baralho_antes - 4, "O baralho deveria ter 4 cartas a menos.")

func test_iniciar_cartas_expostas():
	baralho.cartasTremExpostas.clear()
	baralho.iniciarCartasTremExpostas()
	assert_eq(baralho.cartasTremExpostas.size(), 5, "Deveria haver 5 cartas expostas.")
	for carta in baralho.cartasTremExpostas:
		assert_is(carta, CartaTrem, "Cada item na lista de cartas expostas deveria ser uma CartaTrem.")
