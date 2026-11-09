class_name Card
extends RefCounted

enum CardType {
	ROLE,
	CHARACTER,
	WEAPON,
	ACTION,
	PERMANENT
}

var type: CardType
var card_name: String
var location: Deck = null

func _init(card_type: CardType, name: String):
	type = card_type
	card_name = name
