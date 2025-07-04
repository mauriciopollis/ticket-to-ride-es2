extends Node

var ROSA = Color.PINK
var BRANCO = Color.WHITE
var AZUL = Color.BLUE
var AMARELO = Color.YELLOW
var LARANJA = Color.ORANGE
var PRETO = Color.BLACK
var VERMELHO = Color.RED
var VERDE = Color.GREEN
var CINZA = Color.GRAY
var CURINGA = Color.TRANSPARENT

func nomeCor(cor: Color) -> String:
	if cor == Color.RED:
		return "Vermelho"
	elif cor == Color.BLUE:
		return "Azul"
	elif cor == Color.GREEN:
		return "Verde"
	elif cor == Color.YELLOW:
		return "Amarelo"
	elif cor == Color.BLACK:
		return "Preto"
	elif cor == Color.WHITE:
		return "Branco"
	elif cor == Color.PINK:
		return "Rosa"
	elif cor == Color.ORANGE:
		return "Laranja"
	elif cor == Color.GRAY:
		return "Cinza (sem cor)"
	elif cor == Color.TRANSPARENT or cor.a == 0.0:
		return "Curinga (transparente)"
	else:
		return "Desconhecida (%s)" % cor.to_html()

static func getCorPorNome(nome_cor_string: String) -> Color:
	match nome_cor_string.to_lower():
		"preto": return Color.BLACK
		"azul": return Color.BLUE
		"verde": return Color.GREEN
		"laranja": return Color.ORANGE
		"rosa": return Color.PINK
		"vermelho": return Color.RED
		"branco": return Color.WHITE
		"amarelo": return Color.YELLOW
		"cinza": return Color.GRAY
		"locomotiva": return Color.TRANSPARENT
		"curinga": return Color.TRANSPARENT
		_:
			push_warning("Cor '%s' não reconhecida em getCorPorNome. Retornando Color.TRANSPARENT (Curinga)." % nome_cor_string)
			return Color.TRANSPARENT
