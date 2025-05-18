extends Node

class_name Tabuleiro

var cidades: Dictionary = {} # armazenará referncias a objetos da classe Cidade
var rotas: Array[Rota] = []

func _ready() -> void:
	print("Tabuleiro rodando!")
	configurarTabuleiro()

# push_error: reporta no terminal mas mantém rodando
# assert: quando recebe falso: pode reportar no terminal mas sempre encerra a execução
func configurarTabuleiro():
	cidades.clear()
	rotas.clear()

	configurarCidades()
	configurarRotas()


func configurarCidades():
	var nomesCidades = [
	"Atlanta", "Boston", "Calgary", "Charleston", "Chicago", "Dallas", "Denver",
	"Duluth", "El Paso", "Helena", "Houston", "Kansas City", "Las Vegas", "Little Rock",
	"Los Angeles", "Miami", "Montreal", "Nashville", "New Orleans", "New York",
	"Oklahoma City", "Omaha", "Phoenix", "Pittsburgh", "Portland", "Raleigh",
	"Salt Lake City", "San Francisco", "Santa Fe", "Sault Ste. Marie", "Seattle",
	"St. Louis", "Toronto", "Vancouver", "Washington", "Winnipeg"]

	for nome in nomesCidades:
		if not cidades.has(nome):
			var cidade = Cidade.new(nome)
			cidades[nome] = cidade
		else:
			push_warning("Cidade duplicada ignorada: %s" % nome)

func configurarRotas():
	var listaRotas = [
	["Seattle", "Portland", 1, Color.GRAY],
	["Seattle", "Helena", 6, Color.YELLOW],
	["Seattle", "Calgary", 4, Color.GRAY],
	["Portland", "San Francisco", 5, Color.GREEN],
	["Portland", "Salt Lake City", 6, Color.BLUE],
	["San Francisco", "Salt Lake City", 5, Color.ORANGE],
	["San Francisco", "Los Angeles", 3, Color.PINK],
	["Los Angeles", "Las Vegas", 2, Color.GRAY],
	["Los Angeles", "Phoenix", 3, Color.GRAY],
	["Los Angeles", "El Paso", 6, Color.BLACK],
	["Las Vegas", "Salt Lake City", 3, Color.ORANGE],
	["Salt Lake City", "Helena", 3, Color.PURPLE],
	["Salt Lake City", "Denver", 3, Color.RED],
	["Helena", "Calgary", 4, Color.GRAY],
	["Helena", "Winnipeg", 4, Color.BLUE],
	["Helena", "Duluth", 6, Color.ORANGE],
	["Helena", "Denver", 4, Color.GREEN],
	["Helena", "Omaha", 5, Color.RED],
	["Calgary", "Winnipeg", 6, Color.WHITE],
	["Winnipeg", "Duluth", 4, Color.BLACK],
	["Winnipeg", "Sault Ste. Marie", 6, Color.GRAY],
	["Duluth", "Sault Ste. Marie", 3, Color.GRAY],
	["Duluth", "Omaha", 2, Color.GRAY],
	["Duluth", "Chicago", 3, Color.RED],
	["Omaha", "Denver", 4, Color.PINK],
	["Omaha", "Kansas City", 1, Color.GRAY],
	["Omaha", "Chicago", 4, Color.BLUE],
	["Chicago", "Toronto", 4, Color.WHITE],
	["Chicago", "Pittsburgh", 3, Color.ORANGE],
	["Chicago", "St. Louis", 2, Color.GREEN],
	["Toronto", "Montreal", 3, Color.GRAY],
	["Toronto", "Pittsburgh", 2, Color.GRAY],
	["Montreal", "Boston", 2, Color.GRAY],
	["Boston", "New York", 2, Color.RED],
	["New York", "Washington", 2, Color.ORANGE],
	["New York", "Pittsburgh", 2, Color.WHITE],
	["Washington", "Raleigh", 2, Color.GRAY],
	["Washington", "Pittsburgh", 2, Color.GRAY],
	["Raleigh", "Atlanta", 2, Color.GRAY],
	["Raleigh", "Charleston", 2, Color.GRAY],
	["Atlanta", "Charleston", 2, Color.GRAY],
	["Atlanta", "Nashville", 1, Color.GRAY],
	["Atlanta", "Miami", 5, Color.BLUE],
	["Atlanta", "New Orleans", 4, Color.YELLOW],
	["New Orleans", "Houston", 2, Color.RED],
	["New Orleans", "Little Rock", 3, Color.GREEN],
	["Little Rock", "Nashville", 3, Color.WHITE],
	["Little Rock", "St. Louis", 2, Color.GRAY],
	["Little Rock", "Dallas", 2, Color.GRAY],
	["Dallas", "Houston", 1, Color.GRAY],
	["Dallas", "El Paso", 4, Color.RED],
	["Dallas", "Oklahoma City", 2, Color.GRAY],
	["Houston", "El Paso", 6, Color.GREEN],
	["El Paso", "Phoenix", 3, Color.WHITE],
	["El Paso", "Santa Fe", 2, Color.GRAY],
	["El Paso", "Denver", 4, Color.GREEN],
	["Santa Fe", "Denver", 2, Color.GRAY],
	["Santa Fe", "Oklahoma City", 3, Color.BLUE],
	["Oklahoma City", "Denver", 4, Color.RED],
	["Oklahoma City", "Kansas City", 2, Color.GRAY],
	["Kansas City", "St. Louis", 2, Color.BLUE],
	["St. Louis", "Chicago", 2, Color.WHITE],
	["St. Louis", "Nashville", 2, Color.GRAY],
	["Nashville", "Pittsburgh", 4, Color.YELLOW],
	["Pittsburgh", "New York", 2, Color.GREEN]]

	for rotaInfo in listaRotas:
		var c1 = getCidade(rotaInfo[0])
		var c2 = getCidade(rotaInfo[1])
		if c1 != null and c2 != null:
			var rota = Rota.new(c1, c2, rotaInfo[2], rotaInfo[3])
			rotas.append(rota)
		else:
			push_error("Cidade não encontrada: %s ou %s" % [rotaInfo[0], rotaInfo[1]])
			assert(false)


func getCidade(nome: String) -> Cidade:
	assert(cidades.has(nome), "Cidade não encontrada: %s" % nome) # hard fail: para a execução
	return cidades[nome] 


func conquistarRota(rota: Rota, jogador: Jogador):
	if rota.dono != null:
		push_warning("Rota já reclamada por %s" % rota.dono.nome)
		return
	rota.dono = jogador
	jogador.insereRota(rota)
