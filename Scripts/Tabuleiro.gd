extends Node

class_name Tabuleiro

var cidades: Dictionary = {}
var rotas: Dictionary = {}
var original_polygons: Dictionary = {}
var cartas_em_mesa : Array[CartaTrem] = []
var num_escolhas_realizadas = 0

var TabuleiroData = preload("res://Scripts/TabuleiroData.gd")

@onready var hud = $TextureRect/Hud
var baralho
var decisao = preload("res://Scenes/decisao.tscn")
var cartaOpcao = preload("res://Scenes/CartaUI.tscn")


func _ready() -> void:
	configurar_tabuleiro()
	baralho = Baralho.new()
	add_child(baralho)
	Gamestate.distribuir_cartas(baralho)
	
	baralho.iniciarCartasTremExpostas()
	hud.inicializar(baralho.get_cartas_expostas())
	
	hud.connect("signal_carta_aberta", Callable(self, "_carta_aberta"))

	for rota in $RotasButtons.get_children():
		if rota is Area2D:
			var collision = rota.get_node("CollisionPolygon2D")
			if collision.has_node("Polygon2D"):
				var polygon2d = collision.get_node("Polygon2D")
				polygon2d.color = Color(1, 1, 1, 0) # transparente
			var points = []
			for p in collision.polygon:
				points.append(p)
			original_polygons[rota.name] = points
	ajustar_todos_os_poligonos()
	
	hud.atualiza_pilha_destino(baralho.pilhaBilhetesDestino.size())
	hud.atualiza_pilha_cartas_trem(baralho.pilhaCartasTrem.size())

	print("Tabuleiro rodando!")

func ajustar_todos_os_poligonos():
	var texture_rect = $TextureRect
	var original_size = Vector2(1920, 1080) # tamanho original da imagem
	var current_size = texture_rect.size
	var scale = current_size / original_size

	for rota in $RotasButtons.get_children():
		if rota is Area2D and original_polygons.has(rota.name):
			var collision = rota.get_node("CollisionPolygon2D")
			var new_points = []
			for p in original_polygons[rota.name]:
				new_points.append(Vector2(p.x * scale.x, p.y * scale.y))
			
			collision.polygon = new_points
			if collision.has_node("Polygon2D"):
				var polygon2d = collision.get_node("Polygon2D")
				polygon2d.polygon = new_points

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

func gerar_nome_rota(cidade1: Cidade, cidade2: Cidade) -> String:
	var c1 = cidade1.nome.replace(" ", "").to_lower()
	var c2 = cidade2.nome.replace(" ", "").to_lower()
	var nome_rota = "%s-%s" % [c1, c2]
	if rotas.has(nome_rota + "-1"):
		nome_rota += "-2"
	else:
		nome_rota += "-1"
	return nome_rota

func configurar_rotas():
	for rotaData in TabuleiroData.ROTAS:
		var c1 = get_cidade(rotaData[0])
		var c2 = get_cidade(rotaData[1])
		var nome_rota = gerar_nome_rota(c1, c2)
		#var rota = Rota.new(nome_rota, c1, c2, rotaData[2], rotaData[3])
		var rota = Rota.new(nome_rota, c1, c2, TabuleiroData.COR_DICT[rotaData[2]], rotaData[3])
		rotas[nome_rota] = rota
	# print(rotas)

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
	var jogador_atual = Gamestate.jogador_atual()
	var rota_alvo = rotas[nome_rota]
	var cor_alvo = rota_alvo.cor
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
		if rota_alvo.dono == null and jogador_atual.get_qtd_cartas(cor_alvo)  >= rota_alvo.custo:
			var polygon2d = $RotasButtons.get_node(nome_rota).get_node("CollisionPolygon2D").get_node("Polygon2D")
			var base_color = jogador_atual.cor
			polygon2d.color = Color(base_color.r, base_color.g, base_color.b, 0.75)
			conquistar_rota(rota_alvo, jogador_atual)
			jogador_atual.adicionarVagoesDisponiveis(-rota_alvo.custo)
			if cor_alvo != Color.GRAY:
				jogador_atual.removeNCores(rota_alvo.custo, cor_alvo, baralho)
				Gamestate.proximo_turno()
			else:
				var escolhas = jogador_atual.get_options(rota_alvo.custo)
				var grayout = decisao.instantiate()
				hud.add_child(grayout)
				var display = grayout.get_node("mascara/displaybox")
				for each in escolhas:
					var opt = cartaOpcao.instantiate()
					opt.cor_da_carta = each
					var optbutton = opt.get_node("TextureRect/TextureButton")
					optbutton.connect("pressed", Callable(self, "_on_carta_selecionada").bind(opt, grayout, rota_alvo.custo, baralho))
					display.add_child(opt)
		else:
			print("Cartas insuficientes ou rota já capturada.")
var mouse_over_count: int = 0

func _on_mouse_entered() -> void:
	mouse_over_count += 1
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited() -> void:
	mouse_over_count -= 1
	if mouse_over_count <= 0:
		mouse_over_count = 0
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _on_carta_selecionada(opt, blackout, cost, deck):
	var jogador_atual = Gamestate.jogador_atual()
	hud.remove_child(blackout)
	var color_choice
	if opt.cor_da_carta == "preto":
		color_choice = Color.BLACK
	elif opt.cor_da_carta == "azul":
		color_choice = Color.BLUE
	elif opt.cor_da_carta == "verde":
		color_choice = Color.GREEN
	elif opt.cor_da_carta == "laranja":
		color_choice = Color.ORANGE
	elif opt.cor_da_carta == "rosa":
		color_choice = Color.PINK
	elif opt.cor_da_carta == "vermelho":
		color_choice = Color.RED
	elif opt.cor_da_carta == "branco":
		color_choice = Color.WHITE
	elif opt.cor_da_carta == "amarelo":
		color_choice = Color.YELLOW
	else:
		print("Seleção não prevista para captura de trilha cinza!")
		
	jogador_atual.removeNCores(cost, color_choice, deck)
	Gamestate.proximo_turno()
	
func _carta_aberta(index):
	var cartas_expostas = baralho.get_cartas_expostas()
	num_escolhas_realizadas += 1
	print("Carta numero " + str(index) + " selecionada ")
	print("Cor da carta: " + str(cartas_expostas[index].cor))
	print("Foram realizadas " + str(num_escolhas_realizadas) + " escolhas nesse turno")
	# Verificar condições
	# entregar carta ao jogador, remover das cartas face para cima (e repor uma nova).
	# Lembrar de resetar: num_escolhas_realizadas
	# Lembrar de chamar: hud.atualiza_cartas_abertas(cartas_em_mesa)
	# Lembrar de chamar: Gamestate.proximo_turno() ao fim
	
