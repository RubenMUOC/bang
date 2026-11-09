class_name PlayingCard
extends Card

enum Suit {
	HEARTS,
	DIAMONDS,
	CLUBS,
	SPADES
}

var suit: Suit
var value: int

func _init(type: CardType, name: String, suit: Suit, value: int):
	super(type, name)

	self.suit = suit
	self.value = value
