extends CanvasLayer

@onready var oponenteUI1 = $TextureRect/AdversariosContainer/OponenteUI
@onready var oponenteUI2 = $TextureRect/AdversariosContainer/OponenteUI2
@onready var oponenteUI3 = $TextureRect/AdversariosContainer/OponenteUI3
@onready var oponenteUI4 = $TextureRect/AdversariosContainer/OponenteUI4
@onready var oponenteUIs = [oponenteUI1,oponenteUI2, oponenteUI3, oponenteUI4]
@onready var jogadorDaVezUI =  $TextureRect/JogadorUI

func _ready() -> void:
	oponenteUI1.visible = false
	oponenteUI2.visible = false
	oponenteUI3.visible = false
	oponenteUI4.visible = false

func inicializar(jogadores: Array[Jogador]):
	jogadorDaVezUI.setJogador(jogadores[0])
	
	for i in range(1, jogadores.size()):
		oponenteUIs[i - 1].setJogador(jogadores[i])
		oponenteUIs[i - 1].visible = true
