extends Node

var upgrades : Dictionary = {
	"has_gauntlet": false,
	"dash_enabled": false,
	"shoot_enabled": false,
	#upgrades futuros
	#"components": {
	#}
}

func enable_gauntlet():
	upgrades["has_gauntlet"] = true
	upgrades["dash_enabled"] = true
	upgrades["shoot_enabled"] = true
	

# Da para apagar tudo aquilo e botar so isso eu acho, vê ai se fica salvo
# depois adiciona esse gauntlet q n sei o q diabo é

# nos itens tuy so bota um Upgratemanager.dash_upgrade = true e ja ativa esse diabo
var dash_upgrated := true
var shoot_upgrated := false # botei isso na manopla pra teste
