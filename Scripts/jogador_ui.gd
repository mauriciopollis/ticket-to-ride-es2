extends Control

@export var nome: String = "NomeJogador"
@export var num_tickets: int = 0
@export var num_trens: int = 0
@export var qnt_pontos: int = 0
@export var bg_color: Color = Color("orange")

func _ready():
	$Background/Panel/Label.text = str(nome)
	$Background/HBoxContainer/Container_Ticket/qnt_ticket.text = str(num_tickets)+"x"
	$Background/HBoxContainer/Container_Valores/ContainerTrens/qnt_trens.text = str(num_trens)
	$Background/HBoxContainer/Container_Valores/ContainerPontos/qnt_pontos.text = str(qnt_pontos)
		
	# StyleBoxes são compartilhadas por padrão, 
	# então é necessário clonar, alterar e substituir a stylebox antiga
	var original_stylebox := $Background.get_theme_stylebox("panel") as StyleBoxFlat
	var new_stylebox := original_stylebox.duplicate()
	new_stylebox.bg_color = bg_color
	$Background.add_theme_stylebox_override("panel", new_stylebox)

func setJogador(jogador: Jogador):
	$Background/Panel/Label.text = str(jogador.nome)
	$Background/HBoxContainer/Container_Ticket/qnt_ticket.text = str(jogador.bilhetesDestinoNaMao.size())+"x"
	$Background/HBoxContainer/Container_Valores/ContainerTrens/qnt_trens.text = str(jogador.cartasTremNaMao.size())
	$Background/HBoxContainer/Container_Valores/ContainerPontos/qnt_pontos.text = str(jogador.pontos)
	
	var original_stylebox := $Background.get_theme_stylebox("panel") as StyleBoxFlat
	var new_stylebox := original_stylebox.duplicate()
	new_stylebox.bg_color = jogador.cor
	$Background.add_theme_stylebox_override("panel", new_stylebox)
	
# Função para abrir painel que exibe os objetivos do jogador.
func _on_texture_button_pressed() -> void:
	pass
