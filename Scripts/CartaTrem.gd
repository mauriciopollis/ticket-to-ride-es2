extends Node

class_name CartaTrem

var cor: Color

func _init(cor_:Color) -> void:
	self.cor = cor_

func get_color() -> Color:
	return self.cor

func eh_locomotiva() -> bool:
	return cor == Color.TRANSPARENT
