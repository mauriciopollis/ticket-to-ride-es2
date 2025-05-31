extends Control

var tabuleiro_scene

func _init() -> void:
	tabuleiro_scene = preload("res://Scenes/tabuleiro.tscn").instantiate()
	
func _ready() -> void:
	pass
	
func inicializar(qtdJogadores: int, qtdIAs: int) -> void:
	for i in range(qtdJogadores):
		var lineEdit = LineEdit.new()
		lineEdit.custom_minimum_size = Vector2(0, 75)
		lineEdit.placeholder_text = "Jogador" + str(i + 1)
		$Panel/HBoxContainer/NomesJogadores.add_child(lineEdit)
	for i in range(qtdIAs):
		var lineEdit = LineEdit.new()
		lineEdit.custom_minimum_size = Vector2(0, 75)
		lineEdit.placeholder_text = "IA " + str(i + 1)
		$Panel/HBoxContainer/NomesIAs.add_child(lineEdit)
	
	setup_jogadores()
	
func setup_jogadores() -> void:
	var rng = RandomNumberGenerator.new()
	for lineEdit in $Panel/HBoxContainer/NomesJogadores.get_children():
		var nome: String
		if lineEdit.text == "":
			nome = lineEdit.placeholder_text
		else:
			nome = lineEdit.text
		tabuleiro_scene.jogadoresReais.append(Jogador.new(nome, Color(rng.randf(), rng.randf(), rng.randf())))
		
	for lineEdit in $Panel/HBoxContainer/NomesIAs.get_children():
		var nome: String
		if lineEdit.text == "":
			nome = lineEdit.placeholder_text
		else:
			nome = lineEdit.text
		tabuleiro_scene.jogadoresIA.append(Jogador.new(nome, Color(rng.randf(), rng.randf(), rng.randf())))

func _on_botao_jogar_modo_setup_jogadores_pressed() -> void:
	get_tree().root.add_child(tabuleiro_scene)
