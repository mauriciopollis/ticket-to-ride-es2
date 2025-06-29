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

var _label_ultima_rodada: Label = null

func _ready() -> void:
	oponenteUI1.visible = false
	oponenteUI2.visible = false
	oponenteUI3.visible = false
	oponenteUI4.visible = false
	
	botaoPilhaVagao.connect("pressed", Callable(self, "_on_pilha_vagoes"))
	botaoPilhaBilhete.connect("pressed", Callable(self, "_on_pilha_bilhetes"))
	botaoObjetivosJogador.connect("pressed", Callable(self, "_on_ver_bilhetes"))

	_label_ultima_rodada = Label.new()
	_label_ultima_rodada.text = "ÚLTIMA RODADA!"
	_label_ultima_rodada.add_theme_font_size_override("font_size", 50)
	_label_ultima_rodada.add_theme_color_override("font_color", Color.RED)
	_label_ultima_rodada.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label_ultima_rodada.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label_ultima_rodada.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_label_ultima_rodada.set_offset(SIDE_TOP, 50)
	_label_ultima_rodada.z_index = 100
	_label_ultima_rodada.visible = false
	add_child(_label_ultima_rodada)

	Gamestate.connect("ultima_rodada_iniciada", Callable(self, "_on_ultima_rodada_iniciada"))

func inicializar(cartas_em_mesa):
	atualizar_jogador_da_vez()
	
	atualiza_cartas_abertas(cartas_em_mesa)
	atualiza_mao_atual()
	
func atualizar_jogador_da_vez():
	for oponente_ui_node in oponenteUIs:
		oponente_ui_node.visible = false

	jogadorDaVezUI.setJogador(Gamestate.jogador_atual())
	
	var idx = 0
	for jogador in Gamestate.jogadores:
		if jogador != Gamestate.jogador_atual():
			if idx < oponenteUIs.size():
				oponenteUIs[idx].setJogador(jogador)
				oponenteUIs[idx].visible = true
				idx += 1
			else:
				print("Há mais oponentes do que UIs de oponentes.")
	
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
		match Utils.nomeCor(carta.cor):
			"Preto":
				qnt_cartas_em_mao["preto"] += 1
			"Azul":
				qnt_cartas_em_mao["azul"] += 1
			"Verde":
				qnt_cartas_em_mao["verde"] += 1
			"Laranja":
				qnt_cartas_em_mao["laranja"] += 1
			"Rosa":
				qnt_cartas_em_mao["rosa"] += 1
			"Vermelho":
				qnt_cartas_em_mao["vermelho"] += 1
			"Curinga (transparente)":
				qnt_cartas_em_mao["locomotiva"] += 1
			"Branco":
				qnt_cartas_em_mao["branco"] += 1
			"Amarelo":
				qnt_cartas_em_mao["amarelo"] += 1
	
	var cena_carta = preload("res://Scenes/CartaUI.tscn")

	for cor_nome in qnt_cartas_em_mao:
		if qnt_cartas_em_mao[cor_nome] != 0:
			var carta_ui = cena_carta.instantiate()
			carta_ui.init(cor_nome, qnt_cartas_em_mao[cor_nome])
			maoJogadorAtual.add_child(carta_ui)

func atualiza_cartas_abertas(cartas):
	for i in range(cartasDaMesaUI.size()):
		if i < cartas.size() and cartas[i] != null:
			var textura = load(colorLookUP[str(cartas[i].cor)])
			cartasDaMesaUI[i].get_node("imagem").texture = textura
			cartasDaMesaUI[i].get_node("imagem").visible = true
			var botao = cartasDaMesaUI[i].get_node("imagem/TextureButton")
			for connection in botao.get_signal_connection_list("pressed"):
				botao.disconnect("pressed", connection["callable"])
			botao.connect("pressed", Callable(self, "_on_carta_virada_selecionada").bind(i))
		else:
			cartasDaMesaUI[i].get_node("imagem").visible = false

func _on_carta_virada_selecionada(index):
	emit_signal("signal_carta_aberta", index)

func _on_pilha_vagoes():
	emit_signal("signal_pilha_vagoes")
	
func _on_pilha_bilhetes():
	emit_signal("signal_pilha_bilhetes")

func _on_ver_bilhetes():
	emit_signal("signal_ver_objetivos")

func _on_ultima_rodada_iniciada():
	_label_ultima_rodada.visible = true
