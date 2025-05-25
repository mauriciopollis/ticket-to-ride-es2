extends Node

class_name Tabuleiro

var cidades: Dictionary = {} # armazenará referncias a objetos da classe Cidade
var rotas: Dictionary = {}

const TabuleiroData = preload("res://Scripts/TabuleiroData.gd")

func _ready() -> void:
	print("Tabuleiro rodando!")

	configurar_tabuleiro()

# func print_cidades():
# 	print("Cidades carregadas: ")
# 	for nome in cidades.keys():
# 		print("- ", nome)

# func print_rotas():
# 	print("Rotas carregadas: ")
# 	for rota in rotas:
# 		print("%s -> %s (%d cartas, cor %s)" % [
# 			rota.cidade1.nome,
# 			rota.cidade2.nome,
# 			rota.custo,
# 			Utils.nomeCor(rota.cor)
# 		])

func configurar_tabuleiro():
	cidades.clear()
	rotas.clear()

	configurar_cidades()
	configurar_rotas()

func configurar_cidades():
	for nome in TabuleiroData.CIDADES:
		if not cidades.has(nome):
			var cidade = Cidade.new(nome)
			cidades[nome] = cidade
		else:
			push_warning("Cidade duplicada ignorada: %s" % nome)

func gerar_nome_rota(rota: Rota) -> String:
	var c1 = rota.cidade1.nome.replace(" ", "").to_lower()
	var c2 = rota.cidade2.nome.replace(" ", "").to_lower()
	return "%s-%s-%s" % [c1, c2, rota.cor]

func configurar_rotas():
	for rotaData in TabuleiroData.ROTAS:
		var c1 = get_cidade(rotaData[0])
		var c2 = get_cidade(rotaData[1])
		var rota = Rota.new(c1, c2, rotaData[2], rotaData[3])
		var nome_rota = gerar_nome_rota(rota)
		rotas[nome_rota] = rota
	print(rotas)


func get_cidade(nome: String) -> Cidade:
	assert(cidades.has(nome), "Cidade não encontrada: %s" % nome) # hard fail: para a execução
	return cidades[nome]


func conquistar_rota(rota: Rota, jogador: Jogador):
	if rota.dono != null:
		push_warning("Rota já reclamada por %s" % rota.dono.nome)
		return false

	#jogador.usarCartasTremIA(rota.cor, rota.custo) # tá no lugar errado
	rota.setDono(jogador)
	jogador.inserirRota(rota)
	return true

func _on_rota_input_event(_viewport, event, _shape_idx, nome_rota):
	if event is InputEventMouseButton and event.pressed:
		print("Nome da rota clicada: ", nome_rota)
