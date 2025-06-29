extends GutTest

const Cidade = preload("res://Scripts/Cidade.gd")
const Rota = preload("res://Scripts/Rota.gd")
const Jogador = preload("res://Scripts/Jogador.gd")
const Tabuleiro = preload("res://Scripts/Tabuleiro.gd")

class TabuleiroParaTestes extends Tabuleiro:
	func _init(mock_data_source = {}):
		self.TabuleiroData = mock_data_source

func test_configurar_cidades():
	var mock_data = {
		"CIDADES": ["Lisboa", "Porto", "Madrid"]
	}
	var tabuleiro_para_teste = TabuleiroParaTestes.new(mock_data)
	tabuleiro_para_teste.configurar_cidades()

	assert_eq(tabuleiro_para_teste.cidades.size(), 3, "Deveria ter criado 3 cidades.")
	assert_true(tabuleiro_para_teste.cidades.has("Lisboa"), "Deveria conter a cidade de Lisboa.")
	assert_true(tabuleiro_para_teste.cidades["Lisboa"] is Cidade, "O objeto de Lisboa deveria ser do tipo Cidade.")

func test_configurar_rotas():
	var mock_data = {
		"CIDADES": ["Lisboa", "Porto"],
		"ROTAS": [["Lisboa", "Porto", "azul", 3]],
		"COR_DICT": { "azul": Color.BLUE }
	}
	var tabuleiro_para_teste = TabuleiroParaTestes.new(mock_data)
	
	tabuleiro_para_teste.configurar_cidades()
	tabuleiro_para_teste.configurar_rotas()
	
	assert_eq(tabuleiro_para_teste.rotas.size(), 1, "Deveria ter criado 1 rota.")
	var rota = tabuleiro_para_teste.rotas.values()[0]
	assert_true(rota is Rota, "O objeto da rota deveria ser do tipo Rota.")
	assert_eq(rota.cidade1.nome, "Lisboa", "A cidade 1 deveria ser Lisboa.")
	assert_eq(rota.cidade2.nome, "Porto", "A cidade 2 deveria ser Porto.")
	assert_eq(rota.cor, Color.BLUE, "A cor da rota deveria ser Color.BLUE.")

func test_gerar_nome_rota_simples():
	var tabuleiro = TabuleiroParaTestes.new({})
	var c1 = Cidade.new("Lisboa")
	var c2 = Cidade.new("Porto")
	var nome = tabuleiro.gerar_nome_rota(c1, c2)
	assert_eq(nome, "lisboa-porto-1")

func test_gerar_nome_rota_com_duplicata():
	var tabuleiro = TabuleiroParaTestes.new({})
	var c1 = Cidade.new("Lisboa")
	var c2 = Cidade.new("Porto")
	tabuleiro.rotas["lisboa-porto-1"] = null 
	var nome = tabuleiro.gerar_nome_rota(c1, c2)
	assert_eq(nome, "lisboa-porto-2")

func test_conquistar_rota_falha_sem_cartas():
	var tabuleiro = TabuleiroParaTestes.new({})
	var jogador = Jogador.new("Fulano", Color.RED)
	var cidade1 = Cidade.new("Lisboa")
	var cidade2 = Cidade.new("Porto")
	var rota = Rota.new("lisboa-porto-1", cidade1, cidade2, Color.BLUE, 4)
	
	var conquistado = tabuleiro.conquistar_rota(rota, jogador)
	
	assert_false(conquistado, "Não deveria ser possível conquistar a rota sem cartas.")
	assert_eq(rota.dono, null, "A rota não deveria ter dono.")
	assert_false(jogador.rotas.has(rota), "O jogador não deveria ter a rota.")

func test_conquistar_rota_ja_possuida():
	var tabuleiro = TabuleiroParaTestes.new({})
	var jogador1 = Jogador.new("Fulano", Color.RED)
	var jogador2 = Jogador.new("Ciclano", Color.BLUE)
	var cidade1 = Cidade.new("Lisboa")
	var cidade2 = Cidade.new("Porto")
	var rota = Rota.new("lisboa-porto-1", cidade1, cidade2, Color.BLUE, 4)
	rota.setDono(jogador1)

	var conquistado = tabuleiro.conquistar_rota(rota, jogador2)
	
	assert_false(conquistado, "Não deveria ser possível conquistar uma rota que já tem dono.")
	assert_eq(rota.dono, jogador1, "O dono da rota deveria continuar sendo o jogador 1.")
