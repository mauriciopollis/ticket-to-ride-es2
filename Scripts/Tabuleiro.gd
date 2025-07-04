extends Node

class_name Tabuleiro
var cena_fim = preload("res://Scenes/fim.tscn")

var cidades: Dictionary = {}
var rotas: Dictionary = {}
var original_polygons: Dictionary = {}
var cartas_em_mesa: Array[CartaTrem] = []

var valor_acumulado_selecoes = 0

var bilhetes_oferecidos: Array[BilheteDestino] = []
@onready var numero_destinos_selecionados = 0
@onready var destinos_selecionados_idx = [false, false, false]

var TabuleiroData = preload("res://Scripts/TabuleiroData.gd")

@onready var hud = $TextureRect/Hud

var baralho: Baralho

var decisao = preload("res://Scenes/decisao.tscn")
var cartaOpcao = preload("res://Scenes/CartaUI.tscn")
var bilheteOpcao = preload("res://Scenes/bilhete_ui.tscn")

var ias_instancias: Dictionary = {}

func _ready() -> void:
	print('Tabuleiro rodando!')
	
	configurar_tabuleiro()
	
	baralho = Baralho.new()
	add_child(baralho)

	for jogador in Gamestate.jogadores:
		if jogador.is_ia:
			var nova_ia = IA.new(jogador, self, Gamestate)
			ias_instancias[jogador] = nova_ia
			Gamestate.ias_no_jogo[jogador] = nova_ia
	
	Gamestate.distribuir_cartas(baralho)
	
	baralho.iniciarCartasTremExpostas()
	hud.inicializar(baralho.get_cartas_expostas())
	hud.atualiza_pilha_cartas_trem(baralho.pilhaCartasTrem.size())

	hud.connect("signal_carta_aberta", Callable(self, "_on_carta_aberta_hud"))
	hud.connect("signal_pilha_vagoes", Callable(self, "_on_pilha_vagoes_hud"))
	hud.connect("signal_pilha_bilhetes", Callable(self, "_on_pilha_bilhetes_hud"))
	hud.connect("signal_ver_objetivos", Callable(self, "_on_ver_objetivos_pressionado"))

	Gamestate.connect("forcar_compra_bilhete", Callable(self, "_on_pilha_bilhetes_hud"))

	Gamestate.connect("turno_trocado", Callable(hud, "atualizar_jogador_da_vez"))
	Gamestate.connect("turno_trocado", Callable(hud, "atualiza_mao_atual"))
	Gamestate.connect("turno_trocado", Callable(hud, "atualiza_cartas_abertas").bind(baralho.get_cartas_expostas()))
	# Gamestate.connect("turno_trocado", Callable(hud, "atualiza_pilha_destino").bind(baralho.pilhaBilhetesDestino.size()))
	# Gamestate.connect("turno_trocado", Callable(hud, "atualiza_pilha_cartas_trem").bind(baralho.pilhaCartasTrem.size()))

	for rota in $RotasButtons.get_children():
		if rota is Area2D:
			var collision = rota.get_node("CollisionPolygon2D")
			if collision.has_node("Polygon2D"):
				var polygon2d = collision.get_node("Polygon2D")
				polygon2d.color = Color(1, 1, 1, 0)
			var points = []
			for p in collision.polygon:
				points.append(p)
			original_polygons[rota.name] = points
	ajustar_todos_os_poligonos()
	
	if Gamestate.jogador_atual().is_ia:
		Gamestate.ias_no_jogo[Gamestate.jogador_atual()].tomar_decisao()
	else:
		Gamestate.emit_signal("forcar_compra_bilhete")
	print("Tabuleiro rodando!")

func ajustar_todos_os_poligonos():
	var texture_rect = $TextureRect
	var original_size = Vector2(1920, 1080)
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
		var rota = Rota.new(nome_rota, c1, c2, TabuleiroData.COR_DICT[rotaData[2]], rotaData[3])
		rotas[nome_rota] = rota

func get_cidade(nome: String) -> Cidade:
	assert(cidades.has(nome), "Cidade não encontrada: %s" % nome)
	return cidades[nome]

func conquistar_rota(rota: Rota, jogador: Jogador) -> bool:
	if jogador.fezAcaoPrincipal:
		print(jogador.nome + " já realizou uma ação principal neste turno.")
		return false
	
	if jogador.cartasCompradasNesteTurno > 0:
		print(jogador.nome + " não pode conquistar rota após comprar cartas neste turno.")
		return false
	
	if rota.dono != null:
		push_warning("Rota %s já reclamada por %s" % [rota.nome, rota.dono.nome])
		return false

	# Lógica para impedir conquista de rotas paralelas
	var rota_base_nome = rota.nome.replace("-1", "").replace("-2", "")
	if rotas.has(rota_base_nome + "-1") and rotas.has(rota_base_nome + "-2"):
		var rota_paralela_nome = ""
		if rota.nome.ends_with("-1"):
			rota_paralela_nome = rota_base_nome + "-2"
		elif rota.nome.ends_with("-2"):
			rota_paralela_nome = rota_base_nome + "-1"
		
		if rota_paralela_nome != "":
			var rota_paralela = rotas[rota_paralela_nome]
			if rota_paralela.dono == jogador:
				print("Você já possui a rota paralela %s." % rota_paralela.nome)
				return false

	if jogador.getVagoesDisponiveis() < rota.custo:
		print(jogador.nome + " não tem vagões suficientes para a rota %s." % rota.nome)
		return false

	var cartas_necessarias = jogador.getCartasSuficientesIA(rota.cor, rota.custo)
	if cartas_necessarias.size() != rota.custo:
		print(jogador.nome + " não tem cartas suficientes da cor correta para a rota %s." % rota.nome)
		return false

	jogador.adicionarVagoesDisponiveis(-rota.custo)
	
	rota.setDono(jogador)
	jogador.inserirRota(rota)
	
	jogador.fezAcaoPrincipal = true

	print(jogador.nome + " conquistou a rota: %s (Custo: %d, Cor: %s)" % [rota.nome, rota.custo, Utils.nomeCor(rota.cor)])

	var rota_node = $RotasButtons.get_node(rota.nome)
	if rota_node:
		var polygon2d = rota_node.get_node("CollisionPolygon2D").get_node("Polygon2D")
		var base_color = jogador.cor
		polygon2d.color = Color(base_color.r, base_color.g, base_color.b, 0.75)
	else:
		push_warning("Nó da rota '%s' não encontrado para atualização visual." % rota.nome)
	
	return true

func _on_rota_input_event(_viewport, event, _shape_idx, nome_rota):
	var jogador_atual = Gamestate.jogador_atual()
	var rota_alvo = rotas[nome_rota]
	var cor_alvo = rota_alvo.cor

	if event is InputEventMouseButton and event.button_index == 1 and event.pressed and valor_acumulado_selecoes == 0:
		if jogador_atual.fezAcaoPrincipal:
			print("Você já realizou uma ação principal neste turno.")
			return
		
		var rota_conquistada = conquistar_rota(rota_alvo, jogador_atual)
		
		if rota_conquistada:
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
					optbutton.connect("pressed", Callable(self, "_on_carta_cinza_selecionada").bind(opt, grayout, rota_alvo.custo, baralho))
					display.add_child(opt)
			
			if baralho.pilhaCartasTrem.is_empty():
				baralho.remontarPilhaCartasTrem()
var mouse_over_count: int = 0

func _on_mouse_entered() -> void:
	mouse_over_count += 1
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited() -> void:
	mouse_over_count -= 1
	if mouse_over_count <= 0:
		mouse_over_count = 0
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _on_carta_cinza_selecionada(opt, blackout, cost, deck):
	var jogador_atual = Gamestate.jogador_atual()
	hud.remove_child(blackout)
	var color_choice: Color
	color_choice = Utils.getCorPorNome(opt.cor_da_carta)
	
	if color_choice == Color.TRANSPARENT:
		push_warning("Tentou usar locomotiva como cor principal em rota cinza via UI. Isso não deveria acontecer aqui.")
		return
	
	jogador_atual.removeNCores(cost, color_choice, deck)
	Gamestate.proximo_turno()
	
func _on_carta_aberta_hud(index: int):
	var jogador_atual = Gamestate.jogador_atual()

	if jogador_atual.fezAcaoPrincipal:
		print("Já fez uma ação principal neste turno.")
		return
	if jogador_atual.cartasCompradasNesteTurno >= 2:
		print("Já comprou duas cartas neste turno.")
		return
	if jogador_atual.comprouLocomotivaVisivel:
		print("Já comprou uma locomotiva visível neste turno.")
		return

	var carta_comprada = baralho.cartasTremExpostas[index]
	
	if carta_comprada.eh_locomotiva():
		if jogador_atual.cartasCompradasNesteTurno == 1:
			print("Não pode comprar locomotiva visível como 2° carta.")
			return
		jogador_atual.comprouLocomotivaVisivel = true

	jogador_atual.inserirCartaTrem(carta_comprada)
	baralho.cartasTremExpostas[index] = baralho.comprarPilhaCartasTrem()
	jogador_atual.cartasCompradasNesteTurno += 1
	hud.atualiza_mao_atual()
	hud.atualiza_cartas_abertas(baralho.cartasTremExpostas)
	hud.atualiza_pilha_cartas_trem(baralho.pilhaCartasTrem.size())
	if jogador_atual.cartasCompradasNesteTurno >= 2 or jogador_atual.comprouLocomotivaVisivel:
		Gamestate.proximo_turno()

func _on_pilha_vagoes_hud():
	var jogador_atual = Gamestate.jogador_atual()

	if jogador_atual.fezAcaoPrincipal:
		print("Já fez uma ação principal no turno.")
		return
	if jogador_atual.cartasCompradasNesteTurno >= 2:
		print("Já comprou duas cartas no turno.")
		return
	if jogador_atual.comprouLocomotivaVisivel:
		print("Já comprou uma locomotiva visível noturno.")
		return

	if baralho.pilhaCartasTrem.is_empty():
		if not baralho.descarteCartasTrem.is_empty():
			baralho.remontarPilhaCartasTrem()
			hud.atualiza_pilha_cartas_trem(baralho.pilhaCartasTrem.size())
		else:
			print("Pilha de cartas de trem e descarte vazias.")
			return
		
	var carta_comprada = baralho.comprarPilhaCartasTrem()
	if carta_comprada:
		jogador_atual.inserirCartaTrem(carta_comprada)
		jogador_atual.cartasCompradasNesteTurno += 1
		hud.atualiza_mao_atual()
		hud.atualiza_pilha_cartas_trem(baralho.pilhaCartasTrem.size())
	else:
		print("Não há mais cartas para comprar na pilha.")
		return

	if jogador_atual.cartasCompradasNesteTurno >= 2:
		Gamestate.proximo_turno()

func _on_pilha_bilhetes_hud():
	var jogador_atual = Gamestate.jogador_atual()

	if jogador_atual.fezAcaoPrincipal:
		print("Já fez uma ação principal no turno.")
		return
	
	if jogador_atual.cartasCompradasNesteTurno > 0:
		print("Não pode comprar bilhetes após comprar cartas no mesmo turno.")
		return
	
	jogador_atual.fezAcaoPrincipal = true

	var max_ofertas = baralho.pilhaBilhetesDestino.size()
	if max_ofertas >= 3:
		max_ofertas = 3

	if max_ofertas > 0:
		var selection_mode = decisao.instantiate()
		hud.add_child(selection_mode)
		bilhetes_oferecidos.clear()
		for i in range(max_ofertas):
			var bilhete = baralho.comprarPilhaBilhetesDestino()
			if bilhete:
				bilhetes_oferecidos.append(bilhete)
				var selection_buttonUI = bilheteOpcao.instantiate()
				selection_buttonUI.get_node("TextureRect").texture = load(bilhetes_oferecidos[i].asset_path)
				selection_mode.get_node("mascara/displaybilhetes").add_child(selection_buttonUI)
				var select_button = selection_buttonUI.get_node("TextureRect/TextureButton")
				select_button.connect("pressed", Callable(self, "_on_adiciona_selecao_destino").bind(i, selection_buttonUI))
		
		var confirm_button = selection_mode.get_node("mascara/buttonconfirm")
		confirm_button.visible = true
		confirm_button.connect("pressed", Callable(self, "_on_confirmar_pressed").bind(selection_mode))
		hud.atualiza_pilha_destino(baralho.pilhaBilhetesDestino.size())
		
	else:
		print("Não há bilhetes de destino disponíveis para compra.")
		Gamestate.proximo_turno()
		
func _on_ver_objetivos_pressionado():
	var jogador_atual = Gamestate.jogador_atual()
	var selection_mode = decisao.instantiate()
	
	hud.add_child(selection_mode)
	for bilhete in jogador_atual.get_bilhetesDestinoNaMao():
		var bilheteUI = bilheteOpcao.instantiate()
		bilheteUI.get_node("TextureRect").texture = load(bilhete.asset_path)
		selection_mode.get_node("mascara/displaybilhetes").add_child(bilheteUI)
		if jogador_atual.verifica_bilhete(bilhete):
			bilheteUI.get_node("TextureRect").modulate = Color(0.3, 1, 1)
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
		for i in range(bilhetes_oferecidos.size()):
			if destinos_selecionados_idx[i]:
				jogador_atual.inserirBilheteDestinoNaMao(bilhetes_oferecidos[i])
			else:
				baralho.descartarBilheteDestino(bilhetes_oferecidos[i])
		baralho.mixDescarte()
		
		hud.remove_child(selection_mode)
		numero_destinos_selecionados = 0
		bilhetes_oferecidos.clear()
		destinos_selecionados_idx = [false, false, false]
		Gamestate.proximo_turno()
	else:
		print("Por favor, selecione no mínimo %d bilhete(s) de destino." % num_min_escolhas)

func _sair_ver_bilhetes(selection_mode):
	hud.remove_child(selection_mode)

func get_rota_visual_center(rota_name: String) -> Vector2:
	var rota_node = $RotasButtons.get_node(rota_name)
	if rota_node:
		var collision = rota_node.get_node("CollisionPolygon2D")
		var polygon2d = collision.get_node("Polygon2D")
		
		var polygon_points = polygon2d.polygon
		var centroid = Vector2.ZERO
		if not polygon_points.is_empty():
			for p in polygon_points:
				centroid += p
			centroid /= polygon_points.size()

		return polygon2d.to_global(centroid)
	return Vector2.ZERO
