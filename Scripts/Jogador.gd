extends Object

class_name Jogador

#const Rota = preload("res://Scripts/Rota.gd")

var nome: String
var cor: Color
var pontos: int = 0
var vagoesDisponiveis: int = 45
var rotas: Array[Rota] = []
var grafo: Dictionary = {} # grafo[cidadeChave] -> [cidadeVizinha, rota]
var cartasTremNaMao: Array[CartaTrem] = []
var bilhetesDestinoNaMao: Array[BilheteDestino] = []
var bilhetesDestinoCompletados: Array[BilheteDestino] = []
var ordemDeJogada: int

func _init(nome_: String, cor_: Color):
	self.nome = nome_
	self.cor = cor_

func inserirRota(rota: Rota):
	rotas.append(rota)
	var cidade1 = rota.cidade1
	var cidade2 = rota.cidade2

	if not grafo.has(cidade1): # não existe chave == cidade1
		grafo[cidade1] = []
	if not grafo.has(cidade2):
		grafo[cidade2] = []

	grafo[cidade1].append([cidade2, rota])
	grafo[cidade2].append([cidade1, rota])
	
	pontos += Rota.getPontuacao(rota.custo)
	rota.dono = self

func resetarJogador():
	vagoesDisponiveis = 45
	cartasTremNaMao.clear()
	bilhetesDestinoNaMao.clear()
	bilhetesDestinoCompletados.clear()

func inserirCartaTrem(carta: CartaTrem):
	cartasTremNaMao.append(carta)

func inserirBilheteDestinoNaMao(bilhete: BilheteDestino):
	bilhetesDestinoNaMao.append(bilhete)
# não existe inserirBilheteDestinoCompletado porque só acontece quando remove da da mãos

func removeNCores(quantidade, cor_a_remover, baralho):
	var numeroCorSelecionada = 0
	var numeroLocomotivas = 0
	for carta in cartasTremNaMao:
		if carta.cor == cor_a_remover:
			numeroCorSelecionada += 1
		if carta.cor == Color.TRANSPARENT:
			numeroLocomotivas += 1
	if quantidade > numeroCorSelecionada + numeroLocomotivas:
		print("Alerta: Tentando remover mais cartas do que Jogador possue!")
		return false
	if numeroCorSelecionada >= quantidade:
		for i in range(quantidade):
			removeCartaPorCor(cor_a_remover, baralho)
	else:
		for i in range(numeroCorSelecionada):
			removeCartaPorCor(cor_a_remover, baralho)
		for i in range(quantidade - numeroCorSelecionada):
			removeCartaPorCor(Color.TRANSPARENT, baralho)
	return true

func removeCartaPorCor(cor_remocao: Color, baralho: Baralho):
	for carta in cartasTremNaMao:
		if carta.cor == cor_remocao:
			baralho.descartarCartaTrem(carta)
			cartasTremNaMao.erase(carta)
			return true
	return false

func removerCartaTrem(carta: CartaTrem):
	cartasTremNaMao.erase(carta)

func completarBilheteDestino(bilhete: BilheteDestino): # bilhetes só são removidos quando completados
	bilhetesDestinoCompletados.append(bilhete)
	bilhetesDestinoNaMao.erase(bilhete)

func getCartasSuficientesIA(corRota: Color, custo: int) -> Array[CartaTrem]:
	var corCompativel: bool = corRota == Color.GRAY # se corRota == Color.Gray: corCompativel = True
	var cartasCuringa: Array[CartaTrem] = cartasTremNaMao.filter(func(carta): return carta.cor == Utils.CURINGA)
	var cartasNormais: Array[CartaTrem] = cartasTremNaMao.filter(func(carta): return carta.cor != Utils.CURINGA)
	
	var coresNormais: Array[Color] = []
	for carta in cartasNormais:
		if not coresNormais.has(carta.cor):
			coresNormais.append(carta.cor)
	
	if not corCompativel: # limita se a rota não for cinza
		if corRota in coresNormais:
			coresNormais = [corRota] as Array[Color]
		else:
			coresNormais = [] as Array[Color]
	
	for cor_ in coresNormais: # tenta consumir cartas coloridas
		var cartasDessaCor = cartasNormais.filter(func(carta): return carta.cor == cor_)
		var totalDisponivel = cartasDessaCor.size() + cartasCuringa.size()
		
		if totalDisponivel >= custo:
			var cartasParaUsar = cartasDessaCor.slice(0, min(custo, cartasDessaCor.size()))
			var restantes = custo - cartasParaUsar.size()
			
			if restantes > 0:
				cartasParaUsar += cartasCuringa.slice(0, restantes)
			return cartasParaUsar
	
	if cartasCuringa.size() >= custo:
		return cartasCuringa.slice(0, custo)

	push_warning("Impossível conquistar rota")
	return [] # impossível conquistar a rota
	
func usarCartasTremIA(corRota: Color, custo: int) -> bool:
	var cartas: Array[CartaTrem] = getCartasSuficientesIA(corRota, custo)
	if cartas.size() != custo:
		return false # não usou porque não dá
	for carta in cartas:
		removerCartaTrem(carta)
	return true

func buscarCaminho(cidade1: Cidade, cidade2: Cidade) -> bool:
	if not (grafo.has(cidade1) and grafo.has(cidade2)): # ao menos uma das cidades não existe no sobgrafo
		return false

	var visitados: Dictionary = {} # visitados[cidadeChave] -> bool
	var fila: Array[Cidade] = [cidade1]

	while not fila.is_empty():
		var atual: Cidade = fila.pop_front()
		if atual == cidade2:
			return true
		if visitados.has(atual):
			continue
		visitados[atual] = true
		for vizinho in grafo[atual]:
			fila.append(vizinho[0])

	return false

func validarBilheteDestinoNaMao(fimPartida: bool):
	for bilhete in bilhetesDestinoNaMao:
		if buscarCaminho(bilhete.cidade1, bilhete.cidade2):
			pontos += bilhete.pontos
			completarBilheteDestino(bilhete)
		elif fimPartida: # se não tá no fim da partida, não debita ponto ainda
			pontos -= bilhete.pontos

func buscaProfundidade(cidadeAtual: Cidade, caminhoAtual: Array[Rota]) -> Array[Rota]:
	var melhorCaminho: Array[Rota] = caminhoAtual.duplicate()

	for vizinhoInfo in grafo.get(cidadeAtual, []):
		var proximaCidade: Cidade = vizinhoInfo[0]
		var rota: Rota = vizinhoInfo[1]
		
		if rota in caminhoAtual:
			continue # não mergulha nesse filho

		var novoCaminho: Array[Rota] = caminhoAtual.duplicate()
		novoCaminho.append(rota)
		var resultado = buscaProfundidade(proximaCidade, novoCaminho)
		if resultado.size() > melhorCaminho.size():
			melhorCaminho = resultado

	return melhorCaminho

func getMaiorCaminho() -> Array[Rota]:
	if grafo.is_empty():
		return []

	var maiorCaminho: Array[Rota] = []

	for cidade in grafo.keys():
		var caminho: Array[Rota]
		var resultado: Array[Rota] = buscaProfundidade(cidade, caminho)

		if resultado.size() > maiorCaminho.size():
			maiorCaminho = resultado

	return maiorCaminho

func getVagoesDisponiveis() -> int:
	return self.vagoesDisponiveis

func adicionarVagoesDisponiveis(qtd: int):
	if (-qtd > self.vagoesDisponiveis):
		print("Jogador possuí " + str(self.vagoesDisponiveis) + " e tentou capturar rota de custo " + str(-qtd))
	else:
		self.vagoesDisponiveis += qtd

func get_qtd_cartas(cor_rota: Color) -> int:
	var dist = {
		str(Color.BLACK): 0,
		str(Color.BLUE): 0,
		str(Color.GREEN): 0,
		str(Color.ORANGE): 0,
		str(Color.PINK): 0,
		str(Color.RED): 0,
		str(Color.TRANSPARENT): 0,
		str(Color.WHITE): 0,
		str(Color.YELLOW): 0,
		str(Color.GRAY): -1,
	}
	var key_to_highest = str(Color.GRAY)
	for carta in cartasTremNaMao:
		dist[str(carta.cor)] += 1
		if dist[str(carta.cor)] > dist[key_to_highest] and str(carta.cor) != str(Color.TRANSPARENT):
			key_to_highest = str(carta.cor)
			
	if cor_rota == Color.GRAY:
		return dist[key_to_highest] + dist[str(Color.TRANSPARENT)]
	else:
		return dist[str(cor_rota)] + dist[str(Color.TRANSPARENT)]

func get_options(n_cartas: int) -> Array[String]:
	var escolhas: Array[String] = []
	var dist = {
		str(Color.BLACK): 0,
		str(Color.BLUE): 0,
		str(Color.GREEN): 0,
		str(Color.ORANGE): 0,
		str(Color.PINK): 0,
		str(Color.RED): 0,
		str(Color.TRANSPARENT): 0,
		str(Color.WHITE): 0,
		str(Color.YELLOW): 0,
	}
	for carta in cartasTremNaMao:
		dist[str(carta.cor)] += 1

	for key in dist:
		if key != str(Color.TRANSPARENT) and dist[key] > 0:
			if dist[key] + dist[str(Color.TRANSPARENT)] >= n_cartas:
				if key == str(Color.BLACK):
					escolhas.append("preto")
				elif key == str(Color.BLUE):
					escolhas.append("azul")
				elif key == str(Color.GREEN):
					escolhas.append("verde")
				elif key == str(Color.ORANGE):
					escolhas.append("laranja")
				elif key == str(Color.PINK):
					escolhas.append("rosa")
				elif key == str(Color.RED):
					escolhas.append("vermelho")
				elif key == str(Color.WHITE):
					escolhas.append("branco")
				elif key == str(Color.YELLOW):
					escolhas.append("amarelo")
				else:
					print("Erro ao gerar escolhas para conquista de cinza!")
	return escolhas
