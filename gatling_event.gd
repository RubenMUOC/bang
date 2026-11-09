class_name GatlingEvent
extends Event

var attacker: Player
var queue: Array[Player] = []
var current: Player = null


func _init(game: Game, attacker: Player) -> void:
	super(game)
	self.attacker = attacker


	var start: int = game.players.find(attacker)
	var n: int = game.players.size()
	for offset in range(1, n):
		var p: Player = game.players[(start + offset) % n]
		if p.is_alive():
			queue.append(p)

	_advance()

func can_play(player: Player, card: Card) -> bool:
	if player == null or player != current or not player.is_alive():
		return false
	if card == null or not player.hand.has_card(card):
		return false
	if not (card is ActionCard):
		return false
	return (card as ActionCard).action == ActionCard.Action.MISSED

func play_card(player: Player, card: Card) -> bool:
	if not can_play(player, card):
		return false

	if not game.move_card(card, game.discard_pile):
		return false

	_advance()
	return true

func skip(player: Player) -> void:
	if player != current:
		return

	Rules.deal_damage(game, current, attacker, 1)
	_advance()

func _advance() -> void:
	if game.game_state == game.GameState.FINISHED:
		current = null
		finished = true
		return

	while not queue.is_empty():
		current = queue.pop_front()

		if not current.is_alive():
			continue

		if not Rules.has_missed_card(current):
			Rules.deal_damage(game, current, attacker, 1)

			if game.game_state == game.GameState.FINISHED:
				current = null
				finished = true
				return

			continue

		return

	current = null
	finished = true

func get_actor() -> Player:
	return current
