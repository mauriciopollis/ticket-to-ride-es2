extends Node

class_name Tabuleiro
var cena_fim = preload("res://Scenes/fim.tscn")

var cidades: Dictionary = {}
var rotas: Dictionary = {}
var original_polygons: Dictionary = {}
var cartas_em_mesa : Array[CartaTrem] = []

var valor_acumulado_selecoes = 0

var bilhetes_oferecidos: Array[BilheteDestino] = []
@onready var numero_destinos_selecionados = 0
@onready var destinos_selecionados_idx = [false, false, false]


var TabuleiroData = preload("res://Scripts/TabuleiroData.gd")

@onready var hud = $TextureRect/Hud
var baralho
var decisao = preload("res://Scenes/decisao.tscn")
var cartaOpcao = preload("res://Scenes/CartaUI.tscn")
var bilheteOpcao = preload("res://Scenes/bilhete_ui.tscn")


func _ready() -> void:
	configurar_tabuleiro()
	baralho = Baralho.new()
	add_child(baralho)
	Gamestate.distribuir_cartas(baralho)
	Gamestate.connect("forcar_compra_bilhete", Callable(self, "_compra_pilha_bilhetes"))

	baralho.iniciarCartasTremExpostas()
	hud.inicializar(baralho.get_cartas_expostas())
	
	hud.connect("signal_carta_aberta", Callable(self, "_carta_aberta"))
	hud.connect("signal_pilha_vagoes", Callable(self, "_compra_pilha_vagoes"))
	hud.connect("signal_pilha_bilhetes", Callable(self, "_compra_pilha_bilhetes"))
	hud.connect("signal_ver_objetivos", Callable(self, "_ver_objetivos"))


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
	
	_compra_pilha_bilhetes()
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
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed and valor_acumulado_selecoes == 0:
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
			if baralho.pilhaCartasTrem.is_empty():
				baralho.remontarPilhaCartasTrem()
				hud.atualiza_pilha_cartas_trem(baralho.pilhaCartasTrem.size())
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
	if baralho.pilhaCartasTrem.is_empty():
				baralho.remontarPilhaCartasTrem()
				hud.atualiza_pilha_cartas_trem(baralho.pilhaCartasTrem.size())
	Gamestate.proximo_turno()
	
func _carta_aberta(index):
	var cartas_expostas = baralho.get_cartas_expostas()
	var jogador_atual = Gamestate.jogador_atual()
	var valor_escolha
	if str(cartas_expostas[index].cor) == str(Color.TRANSPARENT):
		valor_escolha = 2
	else:
		valor_escolha = 1
		
	if cartas_expostas.size() == 1 and valor_escolha == 1:
		valor_escolha = 0
		return
		
	if valor_escolha + valor_acumulado_selecoes <= 2:
		jogador_atual.inserirCartaTrem(cartas_expostas[index])
		valor_acumulado_selecoes += valor_escolha
		var nova_carta = baralho.comprarPilhaCartasTrem()
		if baralho.pilhaCartasTrem.is_empty():
			baralho.remontarPilhaCartasTrem()
		if nova_carta != null:
			cartas_expostas[index] = nova_carta
		else:
			hud.cartasDaMesaUI[index].visible = false
			cartas_expostas.remove_at(index)
			hud.cartasDaMesaUI.remove_at(index)

		hud.atualiza_mao_atual()
		hud.atualiza_cartas_abertas(cartas_expostas)
		hud.atualiza_pilha_cartas_trem(baralho.pilhaCartasTrem.size())
	
	if valor_acumulado_selecoes == 2:
		valor_acumulado_selecoes = 0
		Gamestate.proximo_turno()
	
func _compra_pilha_vagoes():
	var jogador_atual = Gamestate.jogador_atual()
	var valor_escolha = 1		
		
	if valor_escolha + valor_acumulado_selecoes <= 2 and not baralho.pilhaCartasTrem.is_empty():
		jogador_atual.inserirCartaTrem(baralho.comprarPilhaCartasTrem())
		if baralho.pilhaCartasTrem.is_empty():
			baralho.remontarPilhaCartasTrem()
		valor_acumulado_selecoes += valor_escolha
		hud.atualiza_mao_atual()
		hud.atualiza_pilha_cartas_trem(baralho.pilhaCartasTrem.size())
	
	if valor_acumulado_selecoes == 2:
		valor_acumulado_selecoes = 0
		Gamestate.proximo_turno()
	
func _compra_pilha_bilhetes():
	var max_ofertas = baralho.pilhaBilhetesDestino.size()
	if valor_acumulado_selecoes > 0:
		return

	if max_ofertas >= 3:
		max_ofertas = 3

	if max_ofertas > 0:
		var selection_mode = decisao.instantiate()
		hud.add_child(selection_mode)
		for i in range(max_ofertas):
			bilhetes_oferecidos.append(baralho.comprarPilhaBilhetesDestino())
			var selection_buttonUI = bilheteOpcao.instantiate()
			selection_buttonUI.get_node("TextureRect").texture = load(bilhetes_oferecidos[i].asset_path)
			selection_mode.get_node("mascara/displaybilhetes").add_child(selection_buttonUI)
			var select_button = selection_buttonUI.get_node("TextureRect/TextureButton")
			select_button.connect("pressed", Callable(self, "_on_adiciona_selecao_destino").bind(i, selection_buttonUI))
		var confirm_button = selection_mode.get_node("mascara/buttonconfirm")
		confirm_button.visible = true
		confirm_button.connect("pressed", Callable(self, "_on_confirmar_pressed").bind(selection_mode))
		hud.atualiza_pilha_destino(baralho.pilhaBilhetesDestino.size())

func _ver_objetivos():
	var jogador_atual = Gamestate.jogador_atual()
	var selection_mode = decisao.instantiate()
	
	hud.add_child(selection_mode)
	for bilhete in jogador_atual.get_bilhetesDestinoNaMao():
		var bilheteUI = bilheteOpcao.instantiate()
		bilheteUI.get_node("TextureRect").texture = load(bilhete.asset_path)
		selection_mode.get_node("mascara/displaybilhetes").add_child(bilheteUI)
		if jogador_atual.verifica_bilhete(bilhete):
			bilheteUI.get_node("TextureRect").modulate = Color(0.3, 1, 1)
	#for bilhete in jogador_atual.get_bilhetesDestinoCompletados():
		#var bilheteUI = bilheteOpcao.instantiate()
		#bilheteUI.get_node("TextureRect").texture = load(bilhete.asset_path)
		#bilheteUI.get_node("TextureRect").modulate = Color(0.5, 1, 1)
		#selection_mode.get_node("mascara/displaybilhetes").add_child(bilheteUI)
	var confirm_button = selection_mode.get_node("mascara/buttonconfirm")
	confirm_button.visible = true
	confirm_button.connect("pressed", Callable(self, "_sair_ver_bilhetes").bind(selection_mode))
	
func _on_adiciona_selecao_destino(i, elem):
	if not destinos_selecionados_idx[i]:
		elem.get_node("TextureRect").modulate = Color(1, 1, 0.5)
		numero_destinos_selecionados += 1
		destinos_selecionados_idx[i] = !destinos_selecionados_idx[i]
	else:
		numero_destinos_selecionados -= 1
		elem.get_node("TextureRect").modulate = Color(1, 1, 1)
		destinos_selecionados_idx[i] = !destinos_selecionados_idx[i]

func _on_confirmar_pressed(selection_mode):
	var jogador_atual = Gamestate.jogador_atual()
	var num_min_escolhas = 1
	if Gamestate.primeiras_rodadas:
		num_min_escolhas = 2

	if numero_destinos_selecionados >= num_min_escolhas:
		for i in range(3):
			if destinos_selecionados_idx[i]:
				jogador_atual.inserirBilheteDestinoNaMao(bilhetes_oferecidos[i])
			else:
				if baralho.pilhaBilhetesDestino.size() > 0:
					baralho.descartarBilheteDestino(bilhetes_oferecidos[i])
					baralho.mixDescarte()
					hud.atualiza_pilha_destino(baralho.pilhaBilhetesDestino.size())
		hud.remove_child(selection_mode)
		numero_destinos_selecionados = 0
		bilhetes_oferecidos = []
		destinos_selecionados_idx = [false, false, false]
		Gamestate.proximo_turno()
	else:
		pass

func _sair_ver_bilhetes(selection_mode):
	#get_tree().change_scene_to_packed(cena_fim)
	#print_tree()
	hud.remove_child(selection_mode)
