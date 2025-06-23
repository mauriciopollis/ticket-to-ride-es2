extends Node

class_name Baralho

@onready var tabuleiro = get_parent() as Tabuleiro

var pilhaCartasTrem: Array[CartaTrem] = []
var pilhaBilhetesDestino: Array[BilheteDestino] = []
var cartasTremExpostas: Array[CartaTrem] = []
var descarteCartasTrem: Array[CartaTrem] = []
var descarteBilhetesDestino: Array[BilheteDestino] = []


func _ready() -> void:
	print('Baralho rodando!')

	montarPilhaCartasTrem()
	embaralharPilhaCartasTrem()
	
	montarPilhaBilhetesDestino()
	embaralharPilhaBilhetesDestino()

func resetarBaralho():
	pilhaCartasTrem.clear()
	pilhaBilhetesDestino.clear()
	cartasTremExpostas.clear()
	descarteCartasTrem.clear()
	descarteBilhetesDestino.clear()
	_ready()

func montarPilhaCartasTrem():
	var cores = [Color.PINK, Color.WHITE, Color.BLUE, Color.YELLOW, Color.ORANGE, Color.BLACK, Color.RED, Color.GREEN, Color.TRANSPARENT]
	# coringa é Color.Transparent
	
	for cor in cores:
		for i in range(12):
			pilhaCartasTrem.append(CartaTrem.new(cor))
		if cor == Color.TRANSPARENT: # 2 cartas coringa a mais que as outras cores
			pilhaCartasTrem.append(CartaTrem.new(cor))
			pilhaCartasTrem.append(CartaTrem.new(cor))

func montarPilhaBilhetesDestino():
	var bilhetesInfo = [
		["Los Angeles", "New York", 21],
		["Duluth", "Houston", 8],
		["Sault St Marie", "Nashville", 8],
		["New York", "Atlanta", 6],
		["Portland", "Nashville", 17],
		["Vancouver", "Montreal", 20],
		["Duluth", "El Paso", 10],
		["Toronto", "Miami", 10],
		["Portland", "Phoenix", 11],
		["Dallas", "New York", 11],
		["Calgary", "Salt Lake City", 7],
		["Calgary", "Phoenix", 13],
		["Los Angeles", "Miami", 20],
		["Winnipeg", "Little Rock", 11],
		["San Francisco", "Atlanta", 17],
		["Kansas City", "Houston", 5],
		["Los Angeles", "Chicago", 16],
		["Denver", "Pittsburgh", 11],
		["Chicago", "Santa Fe", 9],
		["Vancouver", "Santa Fe", 13],
		["Boston", "Miami", 12],
		["Chicago", "New Orleans", 7],
		["Montreal", "Atlanta", 9],
		["Seattle", "New York", 22],
		["Denver", "El Paso", 4],
		["Helena", "Los Angeles", 8],
		["Winnipeg", "Houston", 12],
		["Montreal", "New Orleans", 13],
		["Seattle", "Los Angeles", 9],
		["Boston", "Chicago", 7]
	]

	for info in bilhetesInfo:
		var c1 = tabuleiro.get_cidade(info[0])
		var c2 = tabuleiro.get_cidade(info[1])
		if c1 != null and c2 != null:
			var caminho_asset = "res://Assets/Destinos/" + c1.nome + "_" + c2.nome + ".png"
			var bilhete = BilheteDestino.new(c1, c2, info[2], caminho_asset)
			pilhaBilhetesDestino.append(bilhete)
			print(caminho_asset)
		else:
			push_error("Cidade não encontrada: %s ou %s" % [info[0], info[1]])
			assert(false)

func embaralharPilhaCartasTrem():
	pilhaCartasTrem.shuffle()

func embaralharPilhaBilhetesDestino():
	pilhaBilhetesDestino.shuffle()

func comprarPilhaCartasTrem() -> CartaTrem:
	if pilhaCartasTrem.is_empty():
		remontarPilhaCartasTrem()
	if pilhaCartasTrem.is_empty():
		push_warning("Pilha de cartas e de descarte vazias")
		return null
	return pilhaCartasTrem.pop_back()

func comprarPilhaBilhetesDestino() -> BilheteDestino:
	if pilhaBilhetesDestino.is_empty():
		remontarPilhaBilhetesDestino()
	if pilhaBilhetesDestino.is_empty():
		push_warning("Pilha de cartas e de descarte vazias")
		return null
	return pilhaBilhetesDestino.pop_back()

func remontarPilhaCartasTrem():
	descarteCartasTrem.shuffle()
	pilhaCartasTrem = descarteCartasTrem
	descarteCartasTrem = []

func remontarPilhaBilhetesDestino():
	descarteBilhetesDestino.shuffle()
	pilhaBilhetesDestino = descarteBilhetesDestino
	descarteBilhetesDestino = []

func descartarCartaTrem(carta: CartaTrem):
	descarteCartasTrem.append(carta)

func descartarBilheteDestino(bilhete: BilheteDestino):
	descarteBilhetesDestino.append(bilhete)

func darCartasTremJogador(jogador: Jogador, numCartasTrem: int):
	for i in range(numCartasTrem):
		var carta = comprarPilhaCartasTrem()
		if carta:
			jogador.inserirCartaTrem(carta)

func darBilhetesDestinoJogador(jogador: Jogador, numBilhetesDestino: int):
	for i in range(numBilhetesDestino):
		var carta = comprarPilhaBilhetesDestino()
		if carta:
			jogador.inserirBilheteDestinoNaMao(carta)	

func iniciarCartasTremExpostas():
	for i in range(5):
		cartasTremExpostas.append(self.comprarPilhaCartasTrem())

func get_cartas_expostas():
	return cartasTremExpostas
