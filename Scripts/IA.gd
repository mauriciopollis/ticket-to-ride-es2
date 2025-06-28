extends Object
class_name IA

var jogador: Jogador
var _tabuleiro: Tabuleiro
var _gamestate: Gamestate

func _init(jogador: Jogador, tabuleiro: Tabuleiro, gamestate: Gamestate):
	self.jogador = jogador
	self._tabuleiro = tabuleiro
	self._gamestate = gamestate

func tomar_decisao():
	print("Turno da IA: " + jogador.nome)

	var rotas_disponiveis = _tabuleiro.rotas.values()
	rotas_disponiveis.shuffle()
	rotas_disponiveis.sort_custom(func(a, b): return a.custo < b.custo)

	for rota_candidata in rotas_disponiveis:
		if rota_candidata.dono == null:
			if jogador.getVagoesDisponiveis() >= rota_candidata.custo:
				var cartas_para_usar = jogador.getCartasSuficientesIA(rota_candidata.cor, rota_candidata.custo)
				if cartas_para_usar.size() == rota_candidata.custo:
					print(jogador.nome + " decidiu construir a rota: " + rota_candidata.nome + " (Custo: " + str(rota_candidata.custo) + ", Cor: " + Utils.nomeCor(rota_candidata.cor) + ")")
					
					_tabuleiro.conquistar_rota(rota_candidata, jogador)
					jogador.adicionarVagoesDisponiveis(-rota_candidata.custo)

					for carta_usada in cartas_para_usar:
						jogador.removerCartaTrem(carta_usada)
						_tabuleiro.baralho.descartarCartaTrem(carta_usada)
					
					_gamestate.proximo_turno()
					return

	var cartas_visiveis = _tabuleiro.baralho.get_cartas_expostas()
	var carta_escolhida: CartaTrem = null
	var indice_escolhido: int = -1
	var comprou_locomotiva_visivel_neste_turno = false
	var cartas_compradas_neste_turno = 0

	for i in range(cartas_visiveis.size()):
		if cartas_visiveis[i] and cartas_visiveis[i].eh_locomotiva():
			carta_escolhida = cartas_visiveis[i]
			indice_escolhido = i
			comprou_locomotiva_visivel_neste_turno = true
			break
	
	if carta_escolhida == null:
		for i in range(cartas_visiveis.size()):
			if cartas_visiveis[i] and not cartas_visiveis[i].eh_locomotiva():
				carta_escolhida = cartas_visiveis[i]
				indice_escolhido = i
				break

	if carta_escolhida != null and indice_escolhido != -1:
		jogador.inserirCartaTrem(carta_escolhida)
		_tabuleiro.baralho.cartasTremExpostas[indice_escolhido] = _tabuleiro.baralho.comprarPilhaCartasTrem()
		cartas_compradas_neste_turno += 1

		if not comprou_locomotiva_visivel_neste_turno:
			cartas_visiveis = _tabuleiro.baralho.get_cartas_expostas()
			var segunda_carta_escolhida: CartaTrem = null
			var segundo_indice_escolhido: int = -1

			for i in range(cartas_visiveis.size()):
				if cartas_visiveis[i] and cartas_visiveis[i].eh_locomotiva():
					segunda_carta_escolhida = cartas_visiveis[i]
					segundo_indice_escolhido = i
					break
			
			if segunda_carta_escolhida == null:
				for i in range(cartas_visiveis.size()):
					if cartas_visiveis[i] and not cartas_visiveis[i].eh_locomotiva():
						segunda_carta_escolhida = cartas_visiveis[i]
						segundo_indice_escolhido = i
						break

			if segunda_carta_escolhida != null and segundo_indice_escolhido != -1:
				jogador.inserirCartaTrem(segunda_carta_escolhida)
				_tabuleiro.baralho.cartasTremExpostas[segundo_indice_escolhido] = _tabuleiro.baralho.comprarPilhaCartasTrem()
				cartas_compradas_neste_turno += 1
			else:
				if not _tabuleiro.baralho.pilhaCartasTrem.is_empty():
					var carta_oculta = _tabuleiro.baralho.comprarPilhaCartasTrem()
					if carta_oculta:
						jogador.inserirCartaTrem(carta_oculta)
						cartas_compradas_neste_turno += 1
		
		_gamestate.proximo_turno()
		return

	else:
		for i in range(2):
			if not _tabuleiro.baralho.pilhaCartasTrem.is_empty():
				var carta_oculta = _tabuleiro.baralho.comprarPilhaCartasTrem()
				if carta_oculta:
					jogador.inserirCartaTrem(carta_oculta)
					cartas_compradas_neste_turno += 1
				else:
					break
			else:
				break
		
		if cartas_compradas_neste_turno > 0:
			_gamestate.proximo_turno()
			return

	print(jogador.nome + " não conseguiu construir rotas ou comprar cartas de trem. Comprando bilhetes de destino.")
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
		
		for bilhete in bilhetes_a_manter:
			jogador.inserirBilheteDestinoNaMao(bilhete)
		for bilhete in bilhetes_a_descartar:
			_tabuleiro.baralho.descartarBilheteDestino(bilhete)
		_tabuleiro.baralho.mixDescarte()
		
		_gamestate.proximo_turno()
		return

	print(jogador.nome + " não realizou ações úteis. Pulando turno.")
	_gamestate.proximo_turno()
