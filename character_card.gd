class_name CharacterCard
extends Card

var health: int

func _init(name: String, health: int):
	super(CardType.CHARACTER, name)
	self.health = health
