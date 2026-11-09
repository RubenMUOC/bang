class_name EmporiumEvent
extends Event

var caster: Player
var revealed: Deck
var queue: Array[Player] = []
var current: Player = null

func _init(game: Game, caster: Player) -> void:
	super(game)
	self.caster = caster
	revealed = Deck.new()

	var alive_count := 0
	for p in game.players:
		if p.is_alive():
			alive_count += 1

	_reveal_from_deck(alive_count)

	var start := game.players.find(caster)
	var n := game.players.size()

	for offset in range(n):
		var p := game.players[(start + offset) % n]

		if p.is_alive() and queue.size() < revealed.size():
			queue.append(p)

	_advance()


func _reveal_from_deck(amount: int) -> void:
	if amount <= 0:
		return

	if game.game_deck.size() < amount:
		game.recycle_discard()

	for i in range(amount):
		var card := game.game_deck.get_last_card()

		if card == null:
			break

		game.move_card(card, revealed)

func can_play(player: Player, card: Card) -> bool:
	if player == null or player != current:
		return false
	if not player.is_alive():
		return false
	if card == null or not revealed.has_card(card):
		return false
	return true

func play_card(player: Player, card: Card) -> bool:
	if not can_play(player, card):
		return false

	if not game.move_card(card, player.hand):
		return false

	_advance()
	return true

func can_skip(player: Player) -> bool:
	return false

func _advance() -> void:
	if game.game_state == game.GameState.FINISHED:
		current = null
		finished = true
		return

	if revealed.is_empty():
		current = null
		finished = true
		return

	while not queue.is_empty():
		current = queue.pop_front()
		return

	current = null
	finished = true

func on_finish() -> void:
	for card in revealed.cards.duplicate():
		game.move_card(card, game.discard_pile)

func get_actor() -> Player:
	return current

func get_revealed() -> Deck:
	return revealed
