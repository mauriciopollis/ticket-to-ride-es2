extends GutTest

const Cidade = preload("res://Scripts/Cidade.gd")
const Rota = preload("res://Scripts/Rota.gd")
const Jogador = preload("res://Scripts/Jogador.gd")
const Tabuleiro = preload("res://Scripts/Tabuleiro.gd")

var tabuleiro: Tabuleiro

func before_each():
	tabuleiro = Tabuleiro.new()
	tabuleiro.jogadoresIA = []
	tabuleiro.jogadoresReais = []

func test_configurar_cidades():
	tabuleiro.TabuleiroData = {
		"CIDADES": ["Lisboa", "Porto", "Madrid"]
	}
	tabuleiro.configurar_cidades()
	assert_eq(tabuleiro.cidades.size(), 3)
	assert_true(tabuleiro.cidades.has("Lisboa"))
	assert_true(tabuleiro.cidades["Lisboa"] is Cidade)

func test_configurar_rotas():
	tabuleiro.TabuleiroData = {
		"CIDADES": ["Lisboa", "Porto"],
		"ROTAS": [["Lisboa", "Porto", "azul", 3]]
	}
	tabuleiro.configurar_cidades()
	tabuleiro.configurar_rotas()
	assert_eq(tabuleiro.rotas.size(), 1)
	var rota = tabuleiro.rotas.values()[0]
	assert_true(rota is Rota)
	assert_eq(rota.cidade1.nome, "Lisboa")
	assert_eq(rota.cidade2.nome, "Porto")

func test_gerar_nome_rota_simples():
	var c1 = Cidade.new("Lisboa")
	var c2 = Cidade.new("Porto")
	var nome = tabuleiro.gerar_nome_rota(c1, c2)
	assert_eq(nome, "lisboa-porto-1")

func test_gerar_nome_rota_com_duplicata():
	var c1 = Cidade.new("Lisboa")
	var c2 = Cidade.new("Porto")
	tabuleiro.rotas["lisboa-porto-1"] = null
	var nome = tabuleiro.gerar_nome_rota(c1, c2)
	assert_eq(nome, "lisboa-porto-2")

func test_conquistar_rota_funciona():
	var jogador = Jogador.new("A", Color.RED)
	var cidade1 = Cidade.new("Lisboa")
	var cidade2 = Cidade.new("Porto")
	var rota = Rota.new("lisboa-porto-1", cidade1, cidade2, "azul", 4)

	var conquistado = tabuleiro.conquistar_rota(rota, jogador)
	assert_true(conquistado)
	assert_eq(rota.dono, jogador)
	assert_true(jogador.rotas.has(rota))

func test_conquistar_rota_ja_possuida():
	var jogador1 = Jogador.new("A", Color.RED)
	var jogador2 = Jogador.new("B", Color.BLUE)
	var cidade1 = Cidade.new("Lisboa")
	var cidade2 = Cidade.new("Porto")
	var rota = Rota.new("lisboa-porto-1", cidade1, cidade2, "azul", 4)
	rota.setDono(jogador1)

	var conquistado = tabuleiro.conquistar_rota(rota, jogador2)
	assert_false(conquistado)
	assert_eq(rota.dono, jogador1)
