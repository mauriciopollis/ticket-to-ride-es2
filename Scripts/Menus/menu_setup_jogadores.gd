extends Control

var tabuleiro_scene: PackedScene = preload("res://Scenes/tabuleiro.tscn")

var isModoSolo: bool = false

@onready var botao_jogar_setup = $Panel/HBoxContainer/VBoxContainer2/botao_jogar_modo_setup_jogadores
@onready var botao_voltar_setup = $Panel/HBoxContainer/VBoxContainer2/botao_voltar
@onready var nomes_jogadores_container = $Panel/HBoxContainer/NomesJogadores
@onready var nomes_ias_container = $Panel/HBoxContainer/NomesIAs

func _ready() -> void:
	isModoSolo = Gamestate.isModoSolo
	
	inicializar(Gamestate.qtd_players, Gamestate.qtd_ia)
	
	if botao_jogar_setup:
		botao_jogar_setup.connect("pressed", Callable(self, "_on_botao_jogar_modo_setup_jogadores_pressed"))

	if botao_voltar_setup:
		botao_voltar_setup.connect("pressed", Callable(self, "_on_botao_voltar_pressed"))

func inicializar(qtdJogadores: int, qtdIAs: int) -> void:
	for child in nomes_jogadores_container.get_children():
		child.queue_free()
	for child in nomes_ias_container.get_children():
		child.queue_free()

	for i in range(qtdJogadores):
		var lineEdit = LineEdit.new()
		lineEdit.custom_minimum_size = Vector2(0, 75)
		lineEdit.add_theme_font_size_override("font_size", 30)
		lineEdit.placeholder_text = "Jogador " + str(i + 1)
		nomes_jogadores_container.add_child(lineEdit)
		
	for i in range(qtdIAs):
		var lineEdit = LineEdit.new()
		lineEdit.custom_minimum_size = Vector2(0, 75)
		lineEdit.add_theme_font_size_override("font_size", 30)
		lineEdit.placeholder_text = "IA " + str(i + 1)
		nomes_ias_container.add_child(lineEdit)
	
func setup_jogadores() -> void:
	var nomes_jogadores = []
	var nomes_ias = []
	
	for lineEdit in nomes_jogadores_container.get_children():
		var nome: String = lineEdit.text
		if nome == "":
			nome = lineEdit.placeholder_text
		nomes_jogadores.append(nome)
	
	for lineEdit in nomes_ias_container.get_children():
		var nome: String = lineEdit.text
		if nome == "":
			nome = lineEdit.placeholder_text
		nomes_ias.append(nome)
	
	Gamestate.inicializar_jogadores(nomes_jogadores, nomes_ias)

func _on_botao_jogar_modo_setup_jogadores_pressed() -> void:
	setup_jogadores()
	
	get_tree().change_scene_to_file(tabuleiro_scene.resource_path)

func _on_botao_voltar_pressed() -> void:
	if isModoSolo:
		get_tree().change_scene_to_file("res://Scenes/menu_dificuldade.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/menu_customizar.tscn")
