extends Control

@export var cor_da_carta: String = "azul"
@export var quantia: int = 0

func _ready():
	# seta textura
	var cores_validas = ["amarelo", "azul", "branco", "laranja", "locomotiva", "preto", "rosa", "verde", "vermelho"]
	if cor_da_carta not in cores_validas:
		print("Cor  da carta inválida.")
		cor_da_carta = "404"
	var path: String = "res://Assets/cartas/vagao_" + cor_da_carta + ".png"
	$TextureRect.texture = load(path)
	
	# atribui quantia
	$TextureRect/ColorRect/display_quantidade.text = str(quantia)
 
func init(uma_cor: String, qnt: int):
	cor_da_carta = uma_cor
	quantia = qnt

#func _on_texture_button_pressed() -> void:
	##pass
	#print("Vc clicou na carta " + cor_da_carta + " e vc possue " + str(quantia) + " copias dela.")
	#emit_signal("carta_selecionada", cor_da_carta) 
