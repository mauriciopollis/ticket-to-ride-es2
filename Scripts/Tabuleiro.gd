extends Node

class_name Tabuleiro

var cidades: Dictionary = {} # armazenará referncias a objetos da classe Cidade
var rotas: Dictionary = {}
var original_polygons: Dictionary = {}

var TabuleiroData = preload("res://Scripts/TabuleiroData.gd")

@onready var hud = $TextureRect/Hud
@onready var jogadoresIA: Array[Jogador]
@onready var jogadoresReais: Array[Jogador]
@onready var jogadores: Array[Jogador]

func _ready() -> void:
	print("Tabuleiro rodando!")
	
	jogadores.append_array(jogadoresIA)
	jogadores.append_array(jogadoresReais)
	
	hud.inicializar(jogadores)
	
	configurar_tabuleiro()

	for rota in $RotasButtons.get_children():
		if rota is Area2D:
			var collision = rota.get_node("CollisionPolygon2D")
			if collision.has_node("Polygon2D"):
				var polygon2d = collision.get_node("Polygon2D")
				polygon2d.color = Color(1, 1, 1, 0) # transparente
			var points = []
			for p in collision.polygon:
				points.append(p)
			original_polygons[rota.name] = points

	ajustar_todos_os_poligonos()

func ajustar_todos_os_poligonos():
	var texture_rect = $TextureRect
	var original_size = Vector2(1920, 1080) # tamanho original da imagem
	var current_size = texture_rect.size
	var scale = current_size / original_size

	for rota in $RotasButtons.get_children():
		if rota is Area2D and original_polygons.has(rota.name):
			var collision = rota.get_node("CollisionPolygon2D")
			var new_points = []
			for p in original_polygons[rota.name]:
				new_points.append(Vector2(p.x * scale.x, p.y * scale.y))
			
			collision.polygon = new_points
			if collision.has_node("Polygon2D"):
				var polygon2d = collision.get_node("Polygon2D")
				polygon2d.polygon = new_points

func configurar_tabuleiro():
	cidades.clear()
	rotas.clear()

	configurar_cidades()
	configurar_rotas()

func configurar_cidades():
	for nome in TabuleiroData.CIDADES:
		if not cidades.has(nome):
			var cidade = Cidade.new(nome)
			cidades[nome] = cidade
		else:
			push_warning("Cidade duplicada ignorada: %s" % nome)

func gerar_nome_rota(cidade1: Cidade, cidade2: Cidade) -> String:
	var c1 = cidade1.nome.replace(" ", "").to_lower()
	var c2 = cidade2.nome.replace(" ", "").to_lower()
	var nome_rota = "%s-%s" % [c1, c2]
	if rotas.has(nome_rota + "-1"):
		nome_rota += "-2"
	else:
		nome_rota += "-1"
	return nome_rota

func configurar_rotas():
	for rotaData in TabuleiroData.ROTAS:
		var c1 = get_cidade(rotaData[0])
		var c2 = get_cidade(rotaData[1])
		var nome_rota = gerar_nome_rota(c1, c2)
		var rota = Rota.new(nome_rota, c1, c2, rotaData[2], rotaData[3])
		rotas[nome_rota] = rota
	# print(rotas)

func get_cidade(nome: String) -> Cidade:
	assert(cidades.has(nome), "Cidade não encontrada: %s" % nome) # hard fail: para a execução
	return cidades[nome]

func conquistar_rota(rota: Rota, jogador: Jogador):
	if rota.dono != null:
		push_warning("Rota já reclamada por %s" % rota.dono.nome)
		return false

	#jogador.usarCartasTremIA(rota.cor, rota.custo) # tá no lugar errado
	rota.setDono(jogador)
	jogador.inserirRota(rota)
	return true

func _on_rota_input_event(_viewport, event, _shape_idx, nome_rota):
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
		var polygon2d = $RotasButtons.get_node(nome_rota).get_node("CollisionPolygon2D").get_node("Polygon2D")
		var base_color = TabuleiroData.COR_DICT[rotas[nome_rota].cor]
		# var base_color = Color.BLUE
		polygon2d.color = Color(base_color.r, base_color.g, base_color.b, 0.5)

var mouse_over_count: int = 0

func _on_mouse_entered() -> void:
	mouse_over_count += 1
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited() -> void:
	mouse_over_count -= 1
	if mouse_over_count <= 0:
		mouse_over_count = 0
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
