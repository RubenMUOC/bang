
class_name DuelEvent
extends Event

var attacker: Player
var defender: Player
var current: Player

func _init(game: Game, attacker: Player, defender: Player) -> void:
	super(game)
	self.attacker = attacker
	self.defender = defender
	current = defender

func get_actor() -> Player:
	return current

func can_play(player: Player, card: Card) -> bool:
	if player == null or player != current or not player.is_alive():
		return false

	if card == null or not player.hand.has_card(card):
		return false

	if not card is ActionCard:
		return false

	var action_card := card as ActionCard

	return action_card.action == ActionCard.Action.BANG

func play_card(player: Player, card: Card) -> bool:
	if not can_play(player, card):
		return false

	if not player.hand.remove_card(card):
		return false

	game.discard_card(card)

	if current == defender:
		current = attacker
	else:
		current = defender

	if not Rules.has_bang_card(current):
		skip(current)

	return true

func skip(player: Player) -> void:
	if player != current:
		return

	var loser := current
	var winner := attacker if loser == defender else defender

	Rules.deal_damage(game, loser, winner, 1)
	finished = true
