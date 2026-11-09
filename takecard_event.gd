class_name TakeCardEvent
extends Event

var caster: Player
var target: Player
var destination: Deck

func _init(game: Game, caster: Player, target: Player, destination: Deck) -> void:
	super(game)
	self.caster = caster
	self.target = target
	self.destination = destination

	if game == null or caster == null or target == null or destination == null:
			push_error("TakeCardEvent: parámetros invalidos")
			finished = true
			return

	if not caster.is_alive() or not target.is_alive() or not game.players.has(caster) or not game.players.has(target):
		push_error("TakeCardEvent: jugadores invalidos")
		finished = true

func get_actor() -> Player:
	return caster

func can_play(player: Player, card: Card) -> bool:
	return false

func play_card(player: Player, card: Card) -> bool:
	return false

func skip(player: Player) -> void:
	if finished or player != caster:
		return
	_take_from_hand()

func take_from_in_play(card: Card) -> bool:
	if finished or card == null:
		return false
	if not target.in_play.has_card(card):
		return false
	if not game.move_card(card, destination):
		return false

	finished = true
	return true

func has_hand_option() -> bool:
	return not finished and not target.hand.is_empty()

func _take_from_hand() -> void:
	if finished:
		return

	if target.hand.is_empty():
		finished = true
		return

	var idx := randi() % target.hand.size()
	var taken: Card = target.hand.get_card(idx)

	if taken == null or not game.move_card(taken, destination):
		return

	finished = true
