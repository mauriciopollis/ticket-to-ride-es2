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

func resetarMao(): #não deveria ser resetar jogador?
	vagoesDisponiveis = 45
	cartasTremNaMao.clear()
	bilhetesDestinoNaMao.clear()
	bilhetesDestinoCompletados.clear()


func inserirCartaTrem(carta: CartaTrem):
	cartasTremNaMao.append(carta)

func inserirBilheteDestinoNaMao(bilhete: BilheteDestino): 
	bilhetesDestinoNaMao.append(bilhete)
# não existe inserirBilheteDestinoCompletado porque só acontece quando remove da da mãos

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
		coresNormais = [corRota] if corRota in coresNormais else []
	
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
