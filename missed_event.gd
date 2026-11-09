class_name MissedEvent
extends Event

var attacker: Player
var victim: Player

func _init(game: Game, attacker: Player, victim: Player) -> void:
	super(game)
	self.attacker = attacker
	self.victim = victim

func can_play(player: Player, card: Card) -> bool:
	if player == null or player != victim or not player.is_alive():
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

	finished = true
	return true

func skip(player: Player) -> void:
	if player != victim:
		return

	Rules.deal_damage(game, victim, attacker, 1)
	finished = true

func get_actor() -> Player:
	return victim
