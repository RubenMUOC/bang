class_name ActionCard
extends PlayingCard

enum Action {
	BANG,
	MISSED,
	BEER,
	PANIC,
	CAT_BALOU,
	SALOON,
	INDIANS,
	DUEL,
	GATLING,
	DILIGENCE,
	WELLS_FARGO,
	EMPORIUM
}

var action: Action

func _init(name: String, suit: Suit, value: int, action: Action):
	super(CardType.ACTION, name, suit, value)
	self.action = action
