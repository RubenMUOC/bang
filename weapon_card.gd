class_name WeaponCard
extends PlayingCard

var range: int

func _init(name: String, suit: Suit, value: int, range: int):
	super(CardType.WEAPON, name, suit, value)

	self.range = range
