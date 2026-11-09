class_name Deck
extends RefCounted

var cards: Array[Card] = []

func size() -> int:
	return cards.size()

func is_empty() -> bool:
	return cards.is_empty()

func has_card(card: Card) -> bool:
	return cards.has(card)

func add_card(card: Card) -> void:
	if card == null or has_card(card):
		return
	cards.append(card)
	card.location = self

func remove_card(card: Card) -> bool:
	if not has_card(card):
		return false
	cards.erase(card)
	if card.location == self:
		card.location = null
	return true

func clear() -> void:
	for card in cards:
		if card.location == self:
			card.location = null
	cards.clear()

func shuffle() -> void:
	cards.shuffle()

func get_card(index: int) -> Card:
	if index < 0 or index >= cards.size():
		return null
	return cards[index]

func get_last_card() -> Card:
	return get_card(cards.size() - 1)

# Solo para cartas que no participan en el sistema de piles
func draw() -> Card:
	if cards.is_empty():
		return null
	var card : Card = cards.pop_back()
	card.location = null
	return card
