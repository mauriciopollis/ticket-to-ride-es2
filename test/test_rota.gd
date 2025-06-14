extends GutTest

var Jogador = preload("res://Scripts/Jogador.gd")
var Cidade = preload("res://Scripts/Cidade.gd")
var Rota = preload("res://Scripts/Rota.gd")

func test_criacao_rota():
	var cidade_a = Cidade.new("Cidade A")
	var cidade_b = Cidade.new("Cidade B")

	var rota = Rota.new("Rota AB", cidade_a, cidade_b, "vermelho", 3)

	assert_eq(rota.nome, "Rota AB")
	assert_eq(rota.cidade1, cidade_a)
	assert_eq(rota.cidade2, cidade_b)
	assert_eq(rota.cor, "vermelho")
	assert_eq(rota.custo, 3)
	assert_eq(rota.dono, null)

func test_set_dono():
	var cidade_a = Cidade.new("Cidade A")
	var cidade_b = Cidade.new("Cidade B")
	var jogador = Jogador.new("A", Color.RED)

	var rota = Rota.new("Rota AB", cidade_a, cidade_b, "azul", 2)
	rota.setDono(jogador)

	assert_eq(rota.dono, jogador)
