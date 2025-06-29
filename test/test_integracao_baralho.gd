extends GutTest

const Tabuleiro = preload("res://Scripts/Tabuleiro.gd")
const Jogador = preload("res://Scripts/Jogador.gd")
const Baralho = preload("res://Scripts/Baralho.gd")


class TabuleiroParaIntegracao extends Tabuleiro:
	func _ready():

		print('Dublê de Tabuleiro rodando!')
		configurar_tabuleiro()

		self.baralho = Baralho.new()
		add_child(self.baralho)
		
var tabuleiro: TabuleiroParaIntegracao

func before_each():
	Gamestate.jogadores.clear()
	Gamestate.ias_no_jogo.clear()
	Gamestate.jogador_atual_idx = 0
	
	tabuleiro = TabuleiroParaIntegracao.new()
	add_child_autofree(tabuleiro)


func test_setup_inicial_distribui_cartas_corretamente():
	assert_not_null(tabuleiro.baralho, "O Tabuleiro deveria ter instanciado um Baralho em seu _ready().")
	assert_eq(tabuleiro.baralho.pilhaCartasTrem.size(), 110)
	
	var nomes_jogadores = ["Jogador A", "Jogador B", "Jogador C"]
	Gamestate.inicializar_jogadores(nomes_jogadores, [])

	Gamestate.distribuir_cartas(tabuleiro.baralho)
	
	assert_eq(tabuleiro.baralho.pilhaCartasTrem.size(), 110 - 12)
	for jogador in Gamestate.jogadores:
		assert_eq(jogador.cartasTremNaMao.size(), 4)


func test_esvaziar_pilha_forca_remonte_do_descarte():
	var baralho_real = tabuleiro.baralho
	baralho_real.descarteCartasTrem = baralho_real.pilhaCartasTrem.slice(0, 20)
	baralho_real.pilhaCartasTrem.clear()
	assert_eq(baralho_real.pilhaCartasTrem.size(), 0)
	assert_eq(baralho_real.descarteCartasTrem.size(), 20)

	var carta_comprada = baralho_real.comprarPilhaCartasTrem()
	
	assert_not_null(carta_comprada)
	assert_eq(baralho_real.descarteCartasTrem.size(), 0)
	assert_eq(baralho_real.pilhaCartasTrem.size(), 19)
