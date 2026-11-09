class_name CharacterDeck
extends Deck

func _init():
	add_card(CharacterCard.new("Bart Cassidy", 4))
	add_card(CharacterCard.new("Black Jack", 4))
	add_card(CharacterCard.new("Calamity Janet", 4))
	add_card(CharacterCard.new("El Gringo", 3))
	add_card(CharacterCard.new("Jesse Jones", 4))
	add_card(CharacterCard.new("Jourdonnais", 4))
	add_card(CharacterCard.new("Kit Carlson", 4))
	add_card(CharacterCard.new("Lucky Duke", 4))
	add_card(CharacterCard.new("Paul Regret", 3))
	add_card(CharacterCard.new("Pedro Ramirez", 4))
	add_card(CharacterCard.new("Rose Doolan", 4))
	add_card(CharacterCard.new("Sid Ketchum", 4))
	add_card(CharacterCard.new("Slab the Killer", 4))
	add_card(CharacterCard.new("Suzy Lafayette", 4))
	add_card(CharacterCard.new("Vulture Sam", 4))
	add_card(CharacterCard.new("Willy the Kid", 4))
	
	shuffle()
