extends Object

class_name CartaTrem

var cor: Color
const COR_LOCOMOTIVA: Color = Color(0, 0, 0)

func _init(cor_:Color) -> void:
	self.cor = cor_

func eh_locomotiva() -> bool:
	return self.cor == COR_LOCOMOTIVA
