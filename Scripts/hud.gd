extends CanvasLayer

@onready var oponenteUI1 = $TextureRect/AdversariosContainer/OponenteUI
@onready var oponenteUI2 = $TextureRect/AdversariosContainer/OponenteUI2
@onready var oponenteUI3 = $TextureRect/AdversariosContainer/OponenteUI3
@onready var oponenteUI4 = $TextureRect/AdversariosContainer/OponenteUI4
@onready var oponenteUIs = [oponenteUI1, oponenteUI2, oponenteUI3, oponenteUI4]
@onready var jogadorDaVezUI = $TextureRect/JogadorUI
@onready var imagensCartasDaMesa = [
	"res://Assets/cartas/vagao_amarelo.png",
	"res://Assets/cartas/vagao_azul.png",
	"res://Assets/cartas/vagao_branco.png",
	"res://Assets/cartas/vagao_laranja.png",
	"res://Assets/cartas/vagao_locomotiva.png",
	"res://Assets/cartas/vagao_preto.png",
	"res://Assets/cartas/vagao_rosa.png",
	"res://Assets/cartas/vagao_verde.png",
	"res://Assets/cartas/vagao_vermelho.png"
]

@onready var cartasDaMesa = [
	$TextureRect/VBoxContainer/CartaDaMesa1,
	$TextureRect/VBoxContainer/CartaDaMesa2,
	$TextureRect/VBoxContainer/CartaDaMesa3,
	$TextureRect/VBoxContainer/CartaDaMesa4,
	$TextureRect/VBoxContainer/CartaDaMesa5
]

func _ready() -> void:
	oponenteUI1.visible = false
	oponenteUI2.visible = false
	oponenteUI3.visible = false
	oponenteUI4.visible = false
	Gamestate.connect("turno_trocado", Callable(self, "atualizar_jogador_da_vez"))

func inicializar():
	jogadorDaVezUI.setJogador(Gamestate.jogador_atual())

	var idx = 0
	for i in range(Gamestate.jogadores.size()):
		if i == Gamestate.jogador_atual_idx:
			continue
		oponenteUIs[idx].setJogador(Gamestate.jogadores[i])
		oponenteUIs[idx].visible = true
		idx += 1
	
	for i in range(cartasDaMesa.size()):
		var textura = load(imagensCartasDaMesa.pick_random())
		cartasDaMesa[i].get_node("imagem").texture = textura
	
	# Carrega a cena.
	var carta
	var cena_carta = preload("res://Scenes/CartaUI.tscn")
	# Pegar quantia de cartas do jogador (atualmente sem método para tal)
	#var qnt_cartas_em_mao = [1, 2, 3, 4, 5, 6, 7, 8, 9]
	var qnt_cartas_em_mao = {
	"amarelo": 1,
	"azul": 2,
	"branco": 3,
	"laranja": 4,
	"locomotiva": 0,
	"preto": 6,
	"rosa": 7,
	"verde": 8,
	"vermelho": 9
	}
	
	# Adiciona cartas presentes em mão a UI.
	for cor in qnt_cartas_em_mao:
		if qnt_cartas_em_mao[cor] != 0:
			carta = cena_carta.instantiate()
			carta.init(cor, qnt_cartas_em_mao[cor])
			$TextureRect/MaoJogador.add_child(carta)

func atualizar_jogador_da_vez():
	jogadorDaVezUI.setJogador(Gamestate.jogador_atual())
