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
	
