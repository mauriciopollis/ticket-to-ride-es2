extends Control

var tabuleiro_scene
var isModoSolo: bool = false

func _init() -> void:
	tabuleiro_scene = preload("res://Scenes/tabuleiro.tscn").instantiate()
	
func _ready() -> void:
	isModoSolo = Gamestate.isModoSolo
	inicializar(Gamestate.qtd_players, Gamestate.qtd_ia)
	
func inicializar(qtdJogadores: int, qtdIAs: int) -> void:
	for i in range(qtdJogadores):
		var lineEdit = LineEdit.new()
		lineEdit.custom_minimum_size = Vector2(0, 75)
		lineEdit.add_theme_font_size_override("font_size", 30)
		lineEdit.placeholder_text = "Jogador " + str(i + 1)
		$Panel/HBoxContainer/NomesJogadores.add_child(lineEdit)
		
	for i in range(qtdIAs):
		var lineEdit = LineEdit.new()
		lineEdit.custom_minimum_size = Vector2(0, 75)
		lineEdit.add_theme_font_size_override("font_size", 30)
		lineEdit.placeholder_text = "IA " + str(i + 1)
		$Panel/HBoxContainer/NomesIAs.add_child(lineEdit)
	
func setup_jogadores() -> void:
	var nomes_jogadores = []
	var nomes_ias = []
	for lineEdit in $Panel/HBoxContainer/NomesJogadores.get_children():
		var nome: String = lineEdit.text
		if nome == "":
			nome = lineEdit.placeholder_text
		nomes_jogadores.append(nome)
	for lineEdit in $Panel/HBoxContainer/NomesIAs.get_children():
		var nome: String = lineEdit.text
		if nome == "":
			nome = lineEdit.placeholder_text
		nomes_ias.append(nome)
	Gamestate.inicializar_jogadores(nomes_jogadores, nomes_ias)

func _on_botao_jogar_modo_setup_jogadores_pressed() -> void:
	setup_jogadores()
	#get_tree().root.add_child(tabuleiro_scene)
	get_tree().change_scene_to_file("res://Scenes/tabuleiro.tscn")


func _on_botao_voltar_pressed() -> void:
	if isModoSolo:
		#queue_free()
		get_tree().change_scene_to_file("res://Scenes/menu_dificuldade.tscn")
	else:
		#queue_free()
		get_tree().change_scene_to_file("res://Scenes/menu_customizar.tscn")
