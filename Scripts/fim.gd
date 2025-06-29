extends Control
var all_player_stats = []
var jogadores
var ranking = []

func _ready() -> void:
	jogadores = Gamestate.jogadores
	cria_placeholders()
	rankeia_jogadores()
	fill_stats()

	
func cria_placeholders():
	var jogador_stats = preload("res://Scenes/JogadorStats.tscn")
	for i in range(jogadores.size()):
		all_player_stats.append(jogador_stats.instantiate())
	
	
func fill_stats():
	for i in range(all_player_stats.size()):
		print(i)
		var stats_jogador_i = all_player_stats[i].get_node("Background").get_node("VBoxContainer")
		stats_jogador_i.get_node("Posicao").text = str(i+1) + "º lugar"
		stats_jogador_i.get_node("Nome").text = "Nome: " + str(all_player_stats[i].nome)
		stats_jogador_i.get_node("PontoTrilho").text = "Trilhos: " + str(all_player_stats[i].pontuacao_trilhos_contruidos)
		stats_jogador_i.get_node("PontoBilhete").text = "Objetivos: " + str(all_player_stats[i].pontuacao_cartas_destino)
		stats_jogador_i.get_node("PontoBonus").text = "Bonus: " + str(all_player_stats[i].bonus_maior_rota)
		stats_jogador_i.get_node("PontoTotal").text = "Total: " + str(all_player_stats[i].pontuacao_total)
		

func rankeia_jogadores():
	var maior_rota = -1
	for i in range(jogadores.size()):
		ranking.append(i)
		all_player_stats[i].nome = jogadores[i].nome
		all_player_stats[i].pontuacao_trilhos_contruidos = jogadores[i].pontos
		all_player_stats[i].pontuacao_cartas_destino = jogadores[i].retorna_pontos_de_bilhete()
		all_player_stats[i].tamanho_maior_rota = jogadores[i].retorna_tamanho_do_maior_caminho()
		if all_player_stats[i].tamanho_maior_rota > maior_rota:
			maior_rota = all_player_stats[i].tamanho_maior_rota
			
	for i in range(jogadores.size()):
		if all_player_stats[i].tamanho_maior_rota == maior_rota:
			all_player_stats[i].bonus_maior_rota = 10
		all_player_stats[i].calcula_pontuacao_total()
		#print(str(i) + " - " + str(all_player_stats[i].pontuacao_total))
	
	for i in range(all_player_stats.size()):
		for j in range(i + 1, all_player_stats.size()):
			if all_player_stats[j].pontuacao_total > all_player_stats[i].pontuacao_total:
				var temp = all_player_stats[i]
				all_player_stats[i] = all_player_stats[j]
				all_player_stats[j] = temp
	
	$Background/ContainerGrupos/ContainerVencedor.add_child(all_player_stats[0])
	for i in range(1, all_player_stats.size()):
		$Background/ContainerGrupos/ContainerOutros.add_child(all_player_stats[i])
