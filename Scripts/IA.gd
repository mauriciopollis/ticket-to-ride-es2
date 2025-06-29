extends Object
class_name IA

var jogador: Jogador
var _tabuleiro: Tabuleiro
var _gamestate: Gamestate
var _tela_bloqueio = null
var _label_ia = null

func _init(p_jogador: Jogador, tabuleiro: Tabuleiro, gamestate: Gamestate):
	self.jogador = p_jogador
	self._tabuleiro = tabuleiro
	self._gamestate = gamestate

func tomar_decisao():
	print("Turno da IA: " + jogador.nome)
	
	_mostrar_tela_bloqueio()
	
	await _gamestate.get_tree().create_timer(1.0).timeout

	var rotas_disponiveis = _tabuleiro.rotas.values()
	rotas_disponiveis.shuffle()
	rotas_disponiveis.sort_custom(func(a, b): return a.custo < b.custo)

	for rota_candidata in rotas_disponiveis:
		if rota_candidata.dono == null:
			if jogador.getVagoesDisponiveis() >= rota_candidata.custo:
				var cartas_para_usar = jogador.getCartasSuficientesIA(rota_candidata.cor, rota_candidata.custo)
				if cartas_para_usar.size() == rota_candidata.custo:
					# Mostrar que está analisando a rota
					_atualizar_texto_tela("Analisando rotas disponíveis...")
					await _gamestate.get_tree().create_timer(1.5).timeout
					
					# Mostrar que decidiu construir a rota
					_atualizar_texto_tela("Construindo rota: " + rota_candidata.nome + "\nCusto: " + str(rota_candidata.custo) + " - Cor: " + Utils.nomeCor(rota_candidata.cor))
					
					await _gamestate.get_tree().create_timer(2.5).timeout

					_tabuleiro.conquistar_rota(rota_candidata, jogador)
					jogador.adicionarVagoesDisponiveis(-rota_candidata.custo)

					for carta_usada in cartas_para_usar:
						jogador.removerCartaTrem(carta_usada)
						_tabuleiro.baralho.descartarCartaTrem(carta_usada)
					
					# Delay depois da ação
					await _gamestate.get_tree().create_timer(2).timeout
					
					_remover_tela_bloqueio()
					_gamestate.proximo_turno()
					return

	# Mostrar que está procurando cartas
	_atualizar_texto_tela("Procurando cartas para comprar...")
	await _gamestate.get_tree().create_timer(2.0).timeout

	var cartas_visiveis = _tabuleiro.baralho.get_cartas_expostas()
	var carta_escolhida: CartaTrem = null
	var indice_escolhido: int = -1
	var comprou_locomotiva_visivel_neste_turno = false
	var cartas_compradas_neste_turno = 0

	# Primeiro verifica se há locomotivas disponíveis
	var locomotivas_disponiveis = []
	for i in range(cartas_visiveis.size()):
		if cartas_visiveis[i] and cartas_visiveis[i].eh_locomotiva():
			locomotivas_disponiveis.append(i)
	
	if locomotivas_disponiveis.size() > 0:
		# Escolhe uma locomotiva aleatória a
		var indice_aleatorio = locomotivas_disponiveis[randi() % locomotivas_disponiveis.size()]
		carta_escolhida = cartas_visiveis[indice_aleatorio]
		indice_escolhido = indice_aleatorio
		comprou_locomotiva_visivel_neste_turno = true
	else:
		# Se não há locomotivas, escolhe uma carta normal aleatória
		var cartas_normais_disponiveis = []
		for i in range(cartas_visiveis.size()):
			if cartas_visiveis[i] and not cartas_visiveis[i].eh_locomotiva():
				cartas_normais_disponiveis.append(i)
		
		if cartas_normais_disponiveis.size() > 0:
			var indice_aleatorio = cartas_normais_disponiveis[randi() % cartas_normais_disponiveis.size()]
			carta_escolhida = cartas_visiveis[indice_aleatorio]
			indice_escolhido = indice_aleatorio

	if carta_escolhida != null and indice_escolhido != -1:
		var cor_carta = Utils.nomeCor(carta_escolhida.cor) if not carta_escolhida.eh_locomotiva() else "Locomotiva"
		_atualizar_texto_tela("Comprando carta visível: " + cor_carta)
		await _gamestate.get_tree().create_timer(2).timeout
		
		jogador.inserirCartaTrem(carta_escolhida)
		_tabuleiro.baralho.cartasTremExpostas[indice_escolhido] = _tabuleiro.baralho.comprarPilhaCartasTrem()
		cartas_compradas_neste_turno += 1
		
		# Atualizar HUD após primeira compra
		_tabuleiro.hud.atualiza_cartas_abertas(_tabuleiro.baralho.get_cartas_expostas())
		_tabuleiro.hud.atualiza_pilha_cartas_trem(_tabuleiro.baralho.pilhaCartasTrem.size())

		if not comprou_locomotiva_visivel_neste_turno:
			cartas_visiveis = _tabuleiro.baralho.get_cartas_expostas()
			var segunda_carta_escolhida: CartaTrem = null
			var segundo_indice_escolhido: int = -1

			for i in range(cartas_visiveis.size()):
				if cartas_visiveis[i] and not cartas_visiveis[i].eh_locomotiva():
					segunda_carta_escolhida = cartas_visiveis[i]
					segundo_indice_escolhido = i
					break

			if segunda_carta_escolhida != null and segundo_indice_escolhido != -1:
				var cor_segunda_carta = Utils.nomeCor(segunda_carta_escolhida.cor) if not segunda_carta_escolhida.eh_locomotiva() else "Locomotiva"
				_atualizar_texto_tela("Comprando segunda carta visível: " + cor_segunda_carta)
				await _gamestate.get_tree().create_timer(1.0).timeout
				
				jogador.inserirCartaTrem(segunda_carta_escolhida)
				_tabuleiro.baralho.cartasTremExpostas[segundo_indice_escolhido] = _tabuleiro.baralho.comprarPilhaCartasTrem()
				cartas_compradas_neste_turno += 1
				
				# Atualizar HUD após segunda compra
				_tabuleiro.hud.atualiza_cartas_abertas(_tabuleiro.baralho.get_cartas_expostas())
				_tabuleiro.hud.atualiza_pilha_cartas_trem(_tabuleiro.baralho.pilhaCartasTrem.size())
			else:
				if not _tabuleiro.baralho.pilhaCartasTrem.is_empty():
					_atualizar_texto_tela("Comprando carta da pilha fechada")
					await _gamestate.get_tree().create_timer(1.0).timeout
					var carta_oculta = _tabuleiro.baralho.comprarPilhaCartasTrem()
					if carta_oculta:
						jogador.inserirCartaTrem(carta_oculta)
						cartas_compradas_neste_turno += 1
						
						# Atualizar HUD após compra da pilha fechada
						_tabuleiro.hud.atualiza_pilha_cartas_trem(_tabuleiro.baralho.pilhaCartasTrem.size())
		
		await _gamestate.get_tree().create_timer(2.0).timeout
		
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
					cartas_compradas_neste_turno += 1
					# Pequeno delay entre cartas da pilha
					if i == 0:
						_atualizar_texto_tela("Comprando segunda carta da pilha fechada")
						await _gamestate.get_tree().create_timer(2.0).timeout
				else:
					break
			else:
				break
		
		if cartas_compradas_neste_turno > 0:
			# Delay depois da ação de comprar cartas da pilha
			await _gamestate.get_tree().create_timer(2.0).timeout
			
			_remover_tela_bloqueio()
			_gamestate.proximo_turno()
			return

	# Mostrar que vai comprar bilhetes
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
		
		_remover_tela_bloqueio()
		_gamestate.proximo_turno()
		return

	_atualizar_texto_tela("Finalizando turno...")
	await _gamestate.get_tree().create_timer(1.0).timeout
	_remover_tela_bloqueio()
	_gamestate.proximo_turno()

func _mostrar_tela_bloqueio():
	if _tela_bloqueio == null:
		var ia_bloqueio_scene = preload("res://Scenes/ia_bloqueio.tscn")
		_tela_bloqueio = ia_bloqueio_scene.instantiate()
		
		# Obter referência ao label
		_label_ia = _tela_bloqueio.get_node("mascara/PainelInfo/LabelIA")
		_label_ia.text = "Turno da IA - " + jogador.nome
		
		_tabuleiro.hud.add_child(_tela_bloqueio)

func _atualizar_texto_tela(novo_texto: String):
	if _label_ia != null:
		_label_ia.text = "Turno da IA - " + jogador.nome + "\n\n" + novo_texto

func _remover_tela_bloqueio():
	if _tela_bloqueio != null:
		_tabuleiro.hud.remove_child(_tela_bloqueio)
		_tela_bloqueio.queue_free()
		_tela_bloqueio = null
		_label_ia = null
