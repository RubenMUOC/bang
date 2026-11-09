class_name GameDeck
extends Deck

func _init():
	create_permanent_cards()
	create_weapon_cards()
	create_action_cards()
	
	shuffle()

func create_permanent_cards() -> void:
	add_card(PermanentCard.new("Barril", PlayingCard.Suit.SPADES, 12))
	add_card(PermanentCard.new("Barril", PlayingCard.Suit.SPADES, 13))
	add_card(PermanentCard.new("Dinamita", PlayingCard.Suit.HEARTS, 2))
	add_card(PermanentCard.new("Mira telescópica", PlayingCard.Suit.SPADES, 1))
	add_card(PermanentCard.new("Mustang", PlayingCard.Suit.HEARTS, 8))
	add_card(PermanentCard.new("Mustang", PlayingCard.Suit.HEARTS, 9))
	add_card(PermanentCard.new("Cárcel", PlayingCard.Suit.SPADES, 11))
	add_card(PermanentCard.new("Cárcel", PlayingCard.Suit.HEARTS, 4))
	add_card(PermanentCard.new("Cárcel", PlayingCard.Suit.SPADES, 10))

func create_weapon_cards() -> void:
	add_card(WeaponCard.new("Remington", PlayingCard.Suit.CLUBS, 13, 3))
	add_card(WeaponCard.new("Rev. Carabine", PlayingCard.Suit.CLUBS, 1, 4))
	add_card(WeaponCard.new("Schofield", PlayingCard.Suit.CLUBS, 11, 2))
	add_card(WeaponCard.new("Schofield", PlayingCard.Suit.CLUBS, 12, 2))
	add_card(WeaponCard.new("Schofield", PlayingCard.Suit.SPADES, 13, 2))
	add_card(WeaponCard.new("Volcanic", PlayingCard.Suit.SPADES, 10, 1))
	add_card(WeaponCard.new("Volcanic", PlayingCard.Suit.CLUBS, 10, 1))
	add_card(WeaponCard.new("Winchester", PlayingCard.Suit.SPADES, 8, 5))

func create_action_cards() -> void:
	# BANG! - 25
	add_card(ActionCard.new("BANG!", PlayingCard.Suit.SPADES, 1, ActionCard.Action.BANG))
	add_card(ActionCard.new("BANG!", PlayingCard.Suit.CLUBS, 2, ActionCard.Action.BANG))
	add_card(ActionCard.new("BANG!", PlayingCard.Suit.CLUBS, 3, ActionCard.Action.BANG))
	add_card(ActionCard.new("BANG!", PlayingCard.Suit.CLUBS, 4, ActionCard.Action.BANG))
	add_card(ActionCard.new("BANG!", PlayingCard.Suit.CLUBS, 5, ActionCard.Action.BANG))
	add_card(ActionCard.new("BANG!", PlayingCard.Suit.CLUBS, 6, ActionCard.Action.BANG))
	add_card(ActionCard.new("BANG!", PlayingCard.Suit.CLUBS, 7, ActionCard.Action.BANG))
	add_card(ActionCard.new("BANG!", PlayingCard.Suit.CLUBS, 8, ActionCard.Action.BANG))
	add_card(ActionCard.new("BANG!", PlayingCard.Suit.CLUBS, 9, ActionCard.Action.BANG))
	add_card(ActionCard.new("BANG!", PlayingCard.Suit.DIAMONDS, 1, ActionCard.Action.BANG))
	add_card(ActionCard.new("BANG!", PlayingCard.Suit.DIAMONDS, 2, ActionCard.Action.BANG))
	add_card(ActionCard.new("BANG!", PlayingCard.Suit.DIAMONDS, 3, ActionCard.Action.BANG))
	add_card(ActionCard.new("BANG!", PlayingCard.Suit.DIAMONDS, 4, ActionCard.Action.BANG))
	add_card(ActionCard.new("BANG!", PlayingCard.Suit.DIAMONDS, 5, ActionCard.Action.BANG))
	add_card(ActionCard.new("BANG!", PlayingCard.Suit.DIAMONDS, 6, ActionCard.Action.BANG))
	add_card(ActionCard.new("BANG!", PlayingCard.Suit.DIAMONDS, 7, ActionCard.Action.BANG))
	add_card(ActionCard.new("BANG!", PlayingCard.Suit.DIAMONDS, 8, ActionCard.Action.BANG))
	add_card(ActionCard.new("BANG!", PlayingCard.Suit.DIAMONDS, 9, ActionCard.Action.BANG))
	add_card(ActionCard.new("BANG!", PlayingCard.Suit.DIAMONDS, 10, ActionCard.Action.BANG))
	add_card(ActionCard.new("BANG!", PlayingCard.Suit.DIAMONDS, 11, ActionCard.Action.BANG))
	add_card(ActionCard.new("BANG!", PlayingCard.Suit.DIAMONDS, 12, ActionCard.Action.BANG))
	add_card(ActionCard.new("BANG!", PlayingCard.Suit.DIAMONDS, 13, ActionCard.Action.BANG))
	add_card(ActionCard.new("BANG!", PlayingCard.Suit.HEARTS, 1, ActionCard.Action.BANG))
	add_card(ActionCard.new("BANG!", PlayingCard.Suit.HEARTS, 12, ActionCard.Action.BANG))
	add_card(ActionCard.new("BANG!", PlayingCard.Suit.HEARTS, 13, ActionCard.Action.BANG))

	# CERVEZA - 6
	add_card(ActionCard.new("Cerveza", PlayingCard.Suit.HEARTS, 6, ActionCard.Action.BEER))
	add_card(ActionCard.new("Cerveza", PlayingCard.Suit.HEARTS, 7, ActionCard.Action.BEER))
	add_card(ActionCard.new("Cerveza", PlayingCard.Suit.HEARTS, 8, ActionCard.Action.BEER))
	add_card(ActionCard.new("Cerveza", PlayingCard.Suit.HEARTS, 9, ActionCard.Action.BEER))
	add_card(ActionCard.new("Cerveza", PlayingCard.Suit.HEARTS, 10, ActionCard.Action.BEER))
	add_card(ActionCard.new("Cerveza", PlayingCard.Suit.HEARTS, 11, ActionCard.Action.BEER))

	# CAT BALOU - 4
	add_card(ActionCard.new("Cat Balou", PlayingCard.Suit.HEARTS, 13, ActionCard.Action.CAT_BALOU))
	add_card(ActionCard.new("Cat Balou", PlayingCard.Suit.DIAMONDS, 9, ActionCard.Action.CAT_BALOU))
	add_card(ActionCard.new("Cat Balou", PlayingCard.Suit.DIAMONDS, 10, ActionCard.Action.CAT_BALOU))
	add_card(ActionCard.new("Cat Balou", PlayingCard.Suit.DIAMONDS, 11, ActionCard.Action.CAT_BALOU))

	# DILIGENCIA - 2
	add_card(ActionCard.new("Diligencia", PlayingCard.Suit.SPADES, 9, ActionCard.Action.DILIGENCE))
	add_card(ActionCard.new("Diligencia", PlayingCard.Suit.SPADES, 9, ActionCard.Action.DILIGENCE))

	# DUELO - 3
	add_card(ActionCard.new("Duelo", PlayingCard.Suit.DIAMONDS, 12, ActionCard.Action.DUEL))
	add_card(ActionCard.new("Duelo", PlayingCard.Suit.SPADES, 11, ActionCard.Action.DUEL))
	add_card(ActionCard.new("Duelo", PlayingCard.Suit.CLUBS, 8, ActionCard.Action.DUEL))

	# EMPORIO - 2
	add_card(ActionCard.new("Almacén", PlayingCard.Suit.CLUBS, 9, ActionCard.Action.EMPORIUM))
	add_card(ActionCard.new("Almacén", PlayingCard.Suit.SPADES, 12, ActionCard.Action.EMPORIUM))

	# GATLING - 1
	add_card(ActionCard.new("Gatling", PlayingCard.Suit.HEARTS, 10, ActionCard.Action.GATLING))

	# INDIOS! - 2
	add_card(ActionCard.new("Indios!", PlayingCard.Suit.DIAMONDS, 13, ActionCard.Action.INDIANS))
	add_card(ActionCard.new("Indios!", PlayingCard.Suit.DIAMONDS, 1, ActionCard.Action.INDIANS))

	# FALLASTE - 12
	add_card(ActionCard.new("Fallaste", PlayingCard.Suit.CLUBS, 10, ActionCard.Action.MISSED))
	add_card(ActionCard.new("Fallaste", PlayingCard.Suit.CLUBS, 11, ActionCard.Action.MISSED))
	add_card(ActionCard.new("Fallaste", PlayingCard.Suit.CLUBS, 12, ActionCard.Action.MISSED))
	add_card(ActionCard.new("Fallaste", PlayingCard.Suit.CLUBS, 13, ActionCard.Action.MISSED))
	add_card(ActionCard.new("Fallaste", PlayingCard.Suit.CLUBS, 1, ActionCard.Action.MISSED))
	add_card(ActionCard.new("Fallaste", PlayingCard.Suit.SPADES, 2, ActionCard.Action.MISSED))
	add_card(ActionCard.new("Fallaste", PlayingCard.Suit.SPADES, 3, ActionCard.Action.MISSED))
	add_card(ActionCard.new("Fallaste", PlayingCard.Suit.SPADES, 4, ActionCard.Action.MISSED))
	add_card(ActionCard.new("Fallaste", PlayingCard.Suit.SPADES, 5, ActionCard.Action.MISSED))
	add_card(ActionCard.new("Fallaste", PlayingCard.Suit.SPADES, 6, ActionCard.Action.MISSED))
	add_card(ActionCard.new("Fallaste", PlayingCard.Suit.SPADES, 7, ActionCard.Action.MISSED))
	add_card(ActionCard.new("Fallaste", PlayingCard.Suit.SPADES, 8, ActionCard.Action.MISSED))

	# PÁNICO! - 4
	add_card(ActionCard.new("Pánico!", PlayingCard.Suit.HEARTS, 11, ActionCard.Action.PANIC))
	add_card(ActionCard.new("Pánico!", PlayingCard.Suit.HEARTS, 12, ActionCard.Action.PANIC))
	add_card(ActionCard.new("Pánico!", PlayingCard.Suit.HEARTS, 1, ActionCard.Action.PANIC))
	add_card(ActionCard.new("Pánico!", PlayingCard.Suit.DIAMONDS, 8, ActionCard.Action.PANIC))

	# SALOON - 1
	add_card(ActionCard.new("Salón", PlayingCard.Suit.HEARTS, 5, ActionCard.Action.SALOON))

	# WELLS FARGO - 1
	add_card(ActionCard.new("Wells Fargo", PlayingCard.Suit.HEARTS, 3, ActionCard.Action.WELLS_FARGO))
