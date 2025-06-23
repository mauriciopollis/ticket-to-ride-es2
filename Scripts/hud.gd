extends CanvasLayer

@onready var oponenteUI1 = $TextureRect/AdversariosContainer/OponenteUI
@onready var oponenteUI2 = $TextureRect/AdversariosContainer/OponenteUI2
@onready var oponenteUI3 = $TextureRect/AdversariosContainer/OponenteUI3
@onready var oponenteUI4 = $TextureRect/AdversariosContainer/OponenteUI4
@onready var oponenteUIs = [oponenteUI1, oponenteUI2, oponenteUI3, oponenteUI4]
@onready var jogadorDaVezUI = $TextureRect/JogadorUI
@onready var colorLookUP = {
	str(Color.BLACK): "res://Assets/cartas/vagao_preto.png",
	str(Color.BLUE): "res://Assets/cartas/vagao_azul.png",
	str(Color.GREEN): "res://Assets/cartas/vagao_verde.png",
	str(Color.ORANGE): "res://Assets/cartas/vagao_laranja.png",
	str(Color.PINK): "res://Assets/cartas/vagao_rosa.png",
	str(Color.TRANSPARENT): "res://Assets/cartas/vagao_locomotiva.png",
	str(Color.RED): "res://Assets/cartas/vagao_vermelho.png",
	str(Color.WHITE): "res://Assets/cartas/vagao_branco.png",
	str(Color.YELLOW): "res://Assets/cartas/vagao_amarelo.png",
	}
		
@onready var cartasDaMesaUI = [
	$TextureRect/VBoxContainer/CartaDaMesa1,
	$TextureRect/VBoxContainer/CartaDaMesa2,
	$TextureRect/VBoxContainer/CartaDaMesa3,
	$TextureRect/VBoxContainer/CartaDaMesa4,
	$TextureRect/VBoxContainer/CartaDaMesa5
]
@onready var pilhaDest = $TextureRect/PilhaDeDestinos
@onready var botaoPilhaBilhete = $TextureRect/PilhaDeDestinos.get_node("HBoxContainer/imagem/TexButton")
@onready var pilhaCartasVagao = $TextureRect/PilhaDeCartas
@onready var botaoPilhaVagao = $TextureRect/PilhaDeCartas.get_node("HBoxContainer/imagem/TexButton")
@onready var maoJogadorAtual = $TextureRect/MaoJogador
@onready var elementoJogadorUI = $TextureRect/JogadorUI
@onready var botaoObjetivosJogador = elementoJogadorUI.get_node("Background/HBoxContainer/Container_Ticket/TicketImage/TextureButton")

signal signal_carta_aberta(index)
signal signal_pilha_vagoes
signal signal_pilha_bilhetes
signal signal_ver_objetivos

func _ready() -> void:
	oponenteUI1.visible = false
	oponenteUI2.visible = false
	oponenteUI3.visible = false
	oponenteUI4.visible = false
	Gamestate.connect("turno_trocado", Callable(self, "atualizar_jogador_da_vez"))
	botaoPilhaVagao.connect("pressed", Callable(self, "_on_pilha_vagoes"))
	botaoPilhaBilhete.connect("pressed", Callable(self, "_on_pilha_bilhetes"))
	botaoObjetivosJogador.connect("pressed", Callable(self, "_on_ver_bilhetes"))

func inicializar(cartas_em_mesa):
	jogadorDaVezUI.setJogador(Gamestate.jogador_atual())
	var idx = 0
	for i in range(Gamestate.jogadores.size()):
		if i == Gamestate.jogador_atual_idx:
			continue
		oponenteUIs[idx].setJogador(Gamestate.jogadores[i])
		oponenteUIs[idx].visible = true
		idx += 1

	atualiza_cartas_abertas(cartas_em_mesa)
	atualiza_mao_atual()
	

func atualizar_jogador_da_vez():
	jogadorDaVezUI.setJogador(Gamestate.jogador_atual())
	
	var idx = 0
	for oponente in Gamestate.jogadores_restantes():
		oponenteUIs[idx].setJogador(oponente)
		oponenteUIs[idx].visible = true
		idx += 1

	atualiza_mao_atual()

func atualiza_pilha_destino(n):
	$TextureRect/PilhaDeDestinos/HBoxContainer/qtd_cartas.text = str(n)

func atualiza_pilha_cartas_trem(n):
	$TextureRect/PilhaDeCartas/HBoxContainer/qtd_cartas.text = str(n)

func atualiza_mao_atual():
	for child in maoJogadorAtual.get_children():
		child.queue_free()
	
	var mao_jogador_atual = Gamestate.jogador_atual().cartasTremNaMao
	var qnt_cartas_em_mao = {
	"amarelo": 0,
	"azul": 0,
	"branco": 0,
	"laranja": 0,
	"locomotiva": 0,
	"preto": 0,
	"rosa": 0,
	"verde": 0,
	"vermelho": 0
	}
	
	for carta in mao_jogador_atual:
		match carta.cor:
			Color.BLACK:
				qnt_cartas_em_mao["preto"] += 1
			Color.BLUE:
				qnt_cartas_em_mao["azul"] += 1
			Color.GREEN:
				qnt_cartas_em_mao["verde"] += 1
			Color.ORANGE:
				qnt_cartas_em_mao["laranja"] += 1
			Color.PINK:
				qnt_cartas_em_mao["rosa"] += 1
			Color.RED:
				qnt_cartas_em_mao["vermelho"] += 1
			Color.TRANSPARENT:
				qnt_cartas_em_mao["locomotiva"] += 1
			Color.WHITE:
				qnt_cartas_em_mao["branco"] += 1
			Color.YELLOW:
				qnt_cartas_em_mao["amarelo"] += 1
	
	# Carrega a cena.
	var carta_ui
	var cena_carta = preload("res://Scenes/CartaUI.tscn")

	# Adiciona cartas presentes em mão a UI.
	for cor in qnt_cartas_em_mao:
		if qnt_cartas_em_mao[cor] != 0:
			carta_ui = cena_carta.instantiate()
			carta_ui.init(cor, qnt_cartas_em_mao[cor])
			maoJogadorAtual.add_child(carta_ui)

func atualiza_cartas_abertas(cartas):
	for i in range(5):
		var textura = load(colorLookUP[str(cartas[i].cor)])
		cartasDaMesaUI[i].get_node("imagem").texture = textura
		var botao = cartasDaMesaUI[i].get_node("imagem/TextureButton")
		for connection in botao.get_signal_connection_list("pressed"):
			botao.disconnect("pressed", connection["callable"])
		botao.connect("pressed", Callable(self, "_on_carta_virada_selecionada").bind(i))

func _on_carta_virada_selecionada(index):
	emit_signal("signal_carta_aberta", index)

func _on_pilha_vagoes():
	emit_signal("signal_pilha_vagoes")
	
func _on_pilha_bilhetes():
	emit_signal("signal_pilha_bilhetes")

func _on_ver_bilhetes():
	emit_signal("signal_ver_objetivos")
