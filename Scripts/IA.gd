extends Object
class_name IA

var jogador: Jogador
var _tabuleiro: Tabuleiro
var _gamestate: Gamestate
var _tela_bloqueio = null
var _label_ia = null
var _mascara_ia: ColorRect = null

func _init(p_jogador: Jogador, tabuleiro: Tabuleiro, gamestate: Gamestate):
	self.jogador = p_jogador
	self._tabuleiro = tabuleiro
	self._gamestate = gamestate

func tomar_decisao():
	print("Turno da IA: " + jogador.nome)
	
	_mostrar_tela_bloqueio()
	
	await _gamestate.get_tree().create_timer(1.0).timeout

	# Prioridade 1: Comprar bilhetes de destino se não tiver nenhum
	if jogador.bilhetesDestinoNaMao.is_empty():
		_comprar_bilhetes_destino()
		return # Termina o turno após comprar bilhetes

	var rotas_disponiveis = _tabuleiro.rotas.values()
	rotas_disponiveis.shuffle()
	rotas_disponiveis.sort_custom(func(a, b): return a.custo < b.custo)

	_atualizar_texto_tela("Analisando rotas disponíveis...")

	await _gamestate.get_tree().create_timer(1.5).timeout
	for rota_candidata in rotas_disponiveis:
		if rota_candidata.dono == null:
			if jogador.getVagoesDisponiveis() >= rota_candidata.custo:
				var cartas_para_usar = jogador.getCartasSuficientesIA(rota_candidata.cor, rota_candidata.custo)
				if cartas_para_usar.size() == rota_candidata.custo:
					# Mostrar que está analisando a rota
					var rota_conquistada = _tabuleiro.conquistar_rota(rota_candidata, jogador)
					if rota_conquistada:
						# Mostrar que decidiu construir a rota
						_set_mascara_alpha(0.3)
						_atualizar_texto_tela("Construindo rota: " + rota_candidata.nome + "\nCusto: " + str(rota_candidata.custo) + " - Cor: " + Utils.nomeCor(rota_candidata.cor))
						
						# Adicionar seta na rota
						_mostrar_seta_rota(rota_candidata.nome)
						await _gamestate.get_tree().create_timer(2.5).timeout
						for carta_usada in cartas_para_usar:
							jogador.removerCartaTrem(carta_usada)
							_tabuleiro.baralho.descartarCartaTrem(carta_usada)
						
						# Remover seta da rota e delay depois da ação
						_remover_seta_rota()
						await _gamestate.get_tree().create_timer(0.5).timeout
						_set_mascara_alpha(0.0)
						_remover_tela_bloqueio()
						_gamestate.proximo_turno()
						return
					else:
						# Se não conseguiu conquistar a rota, remove a seta e continua tentando outras rotas
						_remover_seta_rota()
						continue

	_set_mascara_alpha(0.0)
	# Mostrar que está procurando cartas
	_atualizar_texto_tela("Procurando cartas para comprar...")
	await _gamestate.get_tree().create_timer(2.0).timeout

	var cartas_visiveis = _tabuleiro.baralho.get_cartas_expostas()
	var carta_escolhida: CartaTrem = null
	var indice_escolhido: int = -1
	var comprou_locomotiva_visivel_neste_turno = false
	var cartas_compradas_neste_turno = 0

	# Separa as cartas visíveis em locomotivas e não locomotivas
	var locomotivas_visiveis = []
	var nao_locomotivas_visiveis = []
	for i in range(cartas_visiveis.size()):
		if cartas_visiveis[i]:
			if cartas_visiveis[i].eh_locomotiva():
				locomotivas_visiveis.append({"carta": cartas_visiveis[i], "indice": i})
			else:
				nao_locomotivas_visiveis.append({"carta": cartas_visiveis[i], "indice": i})

	# Prioriza locomotivas visíveis na primeira compra
	if not locomotivas_visiveis.is_empty():
		var escolha = locomotivas_visiveis[randi() % locomotivas_visiveis.size()]
		carta_escolhida = escolha.carta
		indice_escolhido = escolha.indice
		comprou_locomotiva_visivel_neste_turno = true
	elif not nao_locomotivas_visiveis.is_empty():
		# Se não houver locomotivas visíveis, escolhe uma carta não locomotiva
		var escolha = nao_locomotivas_visiveis[randi() % nao_locomotivas_visiveis.size()]
		carta_escolhida = escolha.carta
		indice_escolhido = escolha.indice
	
	if carta_escolhida != null and indice_escolhido != -1:
		var cor_carta = Utils.nomeCor(carta_escolhida.cor) if not carta_escolhida.eh_locomotiva() else "Locomotiva"
		_atualizar_texto_tela("Comprando carta visível: " + cor_carta)
		await _gamestate.get_tree().create_timer(1).timeout
		
		jogador.inserirCartaTrem(carta_escolhida)
		_tabuleiro.baralho.cartasTremExpostas[indice_escolhido] = _tabuleiro.baralho.comprarPilhaCartasTrem()
		jogador.cartasCompradasNesteTurno += 1
		cartas_compradas_neste_turno += 1
		_tabuleiro.hud.atualiza_cartas_abertas(_tabuleiro.baralho.get_cartas_expostas()) # Atualiza o HUD
		await _gamestate.get_tree().create_timer(0.5).timeout # Delay após a primeira compra

		if not comprou_locomotiva_visivel_neste_turno:
			cartas_visiveis = _tabuleiro.baralho.get_cartas_expostas()
			var segunda_carta_escolhida: CartaTrem = null
			var segundo_indice_escolhido: int = -1

			# Separa as cartas visíveis novamente para a segunda compra
			locomotivas_visiveis.clear()
			nao_locomotivas_visiveis.clear()
			for i in range(cartas_visiveis.size()):
				if cartas_visiveis[i]:
					if cartas_visiveis[i].eh_locomotiva():
						locomotivas_visiveis.append({"carta": cartas_visiveis[i], "indice": i})
					else:
						nao_locomotivas_visiveis.append({"carta": cartas_visiveis[i], "indice": i})

			# Prioriza cartas não locomotivas para a segunda compra (nunca locomotiva)
			if not nao_locomotivas_visiveis.is_empty():
				var escolha = nao_locomotivas_visiveis[randi() % nao_locomotivas_visiveis.size()]
				segunda_carta_escolhida = escolha.carta
				segundo_indice_escolhido = escolha.indice
			# Não adicionamos um 'elif' para locomotivas aqui, pois a IA não deve comprar uma locomotiva na segunda compra
			
			if segunda_carta_escolhida != null and segundo_indice_escolhido != -1:
				var cor_segunda_carta = Utils.nomeCor(segunda_carta_escolhida.cor)
				_atualizar_texto_tela("Comprando segunda carta visível: " + cor_segunda_carta)
				await _gamestate.get_tree().create_timer(1).timeout
				
				jogador.inserirCartaTrem(segunda_carta_escolhida)
				_tabuleiro.baralho.cartasTremExpostas[segundo_indice_escolhido] = _tabuleiro.baralho.comprarPilhaCartasTrem()
				jogador.cartasCompradasNesteTurno += 1
				cartas_compradas_neste_turno += 1
				_tabuleiro.hud.atualiza_cartas_abertas(_tabuleiro.baralho.get_cartas_expostas()) # Atualiza o HUD
				await _gamestate.get_tree().create_timer(0.5).timeout # Delay após a segunda compra
			else:
				if not _tabuleiro.baralho.pilhaCartasTrem.is_empty():
					_atualizar_texto_tela("Comprando carta da pilha fechada")
					await _gamestate.get_tree().create_timer(1).timeout
					var carta_oculta = _tabuleiro.baralho.comprarPilhaCartasTrem()
					if carta_oculta:
						jogador.inserirCartaTrem(carta_oculta)
						jogador.cartasCompradasNesteTurno += 1
						cartas_compradas_neste_turno += 1
						_tabuleiro.hud.atualiza_pilha_cartas_trem(_tabuleiro.baralho.pilhaCartasTrem.size()) # Atualiza o HUD da pilha
						await _gamestate.get_tree().create_timer(0.5).timeout # Delay após a compra da carta oculta
		
		await _gamestate.get_tree().create_timer(1.0).timeout
		
		_set_mascara_alpha(0.0)
		_remover_tela_bloqueio()
		_gamestate.proximo_turno()
		return

	else:
		_atualizar_texto_tela("Comprando cartas da pilha fechada")
		for i in range(2):
			if not _tabuleiro.baralho.pilhaCartasTrem.is_empty():
				var carta_oculta = _tabuleiro.baralho.comprarPilhaCartasTrem()
				if carta_oculta:
					jogador.inserirCartaTrem(carta_oculta)
					jogador.cartasCompradasNesteTurno += 1
					cartas_compradas_neste_turno += 1
					_tabuleiro.hud.atualiza_pilha_cartas_trem(_tabuleiro.baralho.pilhaCartasTrem.size()) # Atualiza o HUD da pilha
					# Pequeno delay entre cartas da pilha
					if i == 0:
						_atualizar_texto_tela("Comprando segunda carta da pilha fechada")
						await _gamestate.get_tree().create_timer(1.0).timeout # Delay após a primeira compra da pilha
				else:
					break
			else:
				break
		
		if cartas_compradas_neste_turno > 0:
			await _gamestate.get_tree().create_timer(2.0).timeout
			
			_set_mascara_alpha(0.0)
			_remover_tela_bloqueio()
			_gamestate.proximo_turno()
			return

	# Verificar se já comprou cartas neste turno antes de comprar bilhetes
	if jogador.cartasCompradasNesteTurno > 0:
		_atualizar_texto_tela("Não pode comprar bilhetes após comprar cartas no mesmo turno.")
		await _gamestate.get_tree().create_timer(1.0).timeout
		_set_mascara_alpha(0.0)
		_remover_tela_bloqueio()
		_gamestate.proximo_turno()
		return
	
	# Mostrar que vai comprar bilhetes
	_comprar_bilhetes_destino()

func _comprar_bilhetes_destino():
	_atualizar_texto_tela("Comprando bilhetes de destino...")
	await _gamestate.get_tree().create_timer(2.0).timeout
	
	var bilhetes_oferecidos_ia = []
	for i in range(3):
		var bilhete = _tabuleiro.baralho.comprarPilhaBilhetesDestino()
		if bilhete:
			bilhetes_oferecidos_ia.append(bilhete)

	if !bilhetes_oferecidos_ia.is_empty():
		var bilhetes_a_manter = []
		var bilhetes_a_descartar = []
		var num_min_escolhas = 1
		if _gamestate.primeiras_rodadas:
			num_min_escolhas = 2

		for i in range(bilhetes_oferecidos_ia.size()):
			if i < num_min_escolhas:
				bilhetes_a_manter.append(bilhetes_oferecidos_ia[i])
			else:
				bilhetes_a_descartar.append(bilhetes_oferecidos_ia[i])
		
		_atualizar_texto_tela("Escolhendo " + str(bilhetes_a_manter.size()) + " bilhetes de destino")
		
		for bilhete in bilhetes_a_manter:
			jogador.inserirBilheteDestinoNaMao(bilhete)
		for bilhete in bilhetes_a_descartar:
			_tabuleiro.baralho.descartarBilheteDestino(bilhete)
		_tabuleiro.baralho.mixDescarte()
		
		# Delay depois da ação de comprar bilhetes
		await _gamestate.get_tree().create_timer(2.0).timeout
	
	_set_mascara_alpha(0.0)
	_remover_tela_bloqueio()
	_gamestate.proximo_turno()
	return

var _seta_rota: Control = null

func _mostrar_seta_rota(rota_name: String):
	if _seta_rota == null:
		_seta_rota = Control.new()
		print("Criado _seta_rota como: " + str(_seta_rota.get_class())) # DEBUG
		_seta_rota.size = Vector2(80, 80) # Tamanho da área de desenho
		# Conecta o sinal "draw" do Control ao nosso método de desenho
		_seta_rota.connect("draw", Callable(self, "_on_seta_rota_draw"))
		_tabuleiro.hud.add_child(_seta_rota)

	var rota_center_pos = _tabuleiro.get_rota_visual_center(rota_name)
	_seta_rota.global_position = rota_center_pos - (_seta_rota.size / 2) # Centraliza o Control na rota
	_seta_rota.visible = true
	_seta_rota.queue_redraw() # Força o Control a redesenhar (chama _on_seta_rota_draw)

func _on_seta_rota_draw():
	print("_on_seta_rota_draw chamado!") # DEBUG
	# Desenha um círculo preenchido no centro do _seta_rota
	var center = _seta_rota.size / 2
	var radius = _seta_rota.size.x / 4 # Raio menor para um círculo menor
	_seta_rota.draw_circle(center, radius, jogador.cor) # Círculo com a cor do jogador

func _remover_seta_rota():
	if _seta_rota != null:
		_seta_rota.visible = false
		_seta_rota.queue_free()
		_seta_rota = null

func _mostrar_tela_bloqueio():
	if _tela_bloqueio == null:
		var ia_bloqueio_scene = preload("res://Scenes/ia_bloqueio.tscn")
		_tela_bloqueio = ia_bloqueio_scene.instantiate()
		
		# Obter referência ao label e mascara
		_label_ia = _tela_bloqueio.get_node("mascara/PainelInfo/LabelIA")
		_mascara_ia = _tela_bloqueio.get_node("mascara")
		_tabuleiro.hud.add_child(_tela_bloqueio)
		_set_mascara_alpha(0.0) # Garante que inicie transparente

func _set_mascara_alpha(alpha: float):
	if _mascara_ia:
		var current_color = _mascara_ia.color
		_mascara_ia.color = Color(current_color.r, current_color.g, current_color.b, alpha)

func _remover_tela_bloqueio():
	if _tela_bloqueio != null:
		_tabuleiro.hud.remove_child(_tela_bloqueio)
		_tela_bloqueio.queue_free()
		_tela_bloqueio = null
		_label_ia = null

func _atualizar_texto_tela(texto: String):
	if _label_ia:
		_label_ia.text = "Turno da IA - " + jogador.nome + "\n\n" + texto
