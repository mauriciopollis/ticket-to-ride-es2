extends Control

@onready var tabuleiro_scene = preload("res://Scenes/tabuleiro.tscn").instantiate()

func _init() -> void:
	pass
	
func _ready() -> void:
	pass
	
func inicializar(qtdJogadores: int, qtdIAs: int) -> void:
	for i in range(qtdJogadores):
		var lineEdit = LineEdit.new()
		$Panel/HBoxContainer/NomesJogadores.add_child(lineEdit)
	for i in range(qtdIAs):
		$Panel/HBoxContainer/NomesIAs.add_child(LineEdit.new())
	
func setup_Jogadores() -> void:
	var rng = RandomNumberGenerator.new()
	for lineEdit in $Panel/HBoxContainer/NomesJogadores.get_children():
		tabuleiro_scene.jogadoresReais.append(Jogador.new(lineEdit.text, Color(rng.randf(), rng.randf(), rng.randf())))
		
	for lineEdit in $Panel/HBoxContainer/NomesIAs.get_children():
		tabuleiro_scene.jogadoresIAs.append(Jogador.new(lineEdit.text, Color(rng.randf(), rng.randf(), rng.randf())))
