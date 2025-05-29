extends Control

@export var nome: String = "NomeJogador"
@export var num_tickets: int = 0
@export var qnt_cartas: int = 0
@export var num_trens: int = 0
@export var qnt_pontos: int = 0
@export var bg_color: Color = Color("orange")

func _ready():
	$Panel/GridContainer/ContainerTicket/num_tickets.text = str(num_tickets)
	$Panel/GridContainer/ContainerCartas/qnt_cartas.text = str(qnt_cartas)
	$Panel/GridContainer/ContainerTrens/num_trens.text = str(num_trens)
	$Panel/GridContainer/ContainerPontos/qnt_pontos.text = str(qnt_pontos)
	$Panel/NameBar/NameLabel.text = nome
		
	# StyleBoxes são compartilhadas por padrão, 
	# então é necessário clonar, alterar e substituir a stylebox antiga
	var original_stylebox := $Panel.get_theme_stylebox("panel") as StyleBoxFlat
	var new_stylebox := original_stylebox.duplicate()
	new_stylebox.bg_color = bg_color
	$Panel.add_theme_stylebox_override("panel", new_stylebox)
	
func setJogador(jogador: Jogador):
	$Panel/GridContainer/ContainerTicket/num_tickets.text = str(jogador.bilhetesDestinoNaMao.size())
	$Panel/GridContainer/ContainerCartas/qnt_cartas.text = str(jogador.cartasTremNaMao.size())
	$Panel/GridContainer/ContainerTrens/num_trens.text = str(jogador.cartasTremNaMao.size())
	$Panel/GridContainer/ContainerPontos/qnt_pontos.text = str(jogador.pontos)
	$Panel/NameBar/NameLabel.text = jogador.nome
	var original_stylebox := $Panel.get_theme_stylebox("panel") as StyleBoxFlat
	var new_stylebox := original_stylebox.duplicate()
	new_stylebox.bg_color = jogador.cor
	$Panel.add_theme_stylebox_override("panel", new_stylebox)
