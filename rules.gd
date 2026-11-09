class_name Rules
extends RefCounted

enum VictoryResult {
	NONE,
	LAW,
	OUTLAWS,
	RENEGADE
}

static func can_play_card(game: Game, player: Player, card: Card, target: Player = null) -> bool:
	if player == null or card == null:
		return false

	if not player.is_alive():
		return false

	if not player.hand.has_card(card):
		return false

	if card is ActionCard:
		var action_card := card as ActionCard

		if action_card.action == ActionCard.Action.BANG:
			var w := player.get_weapon()
			if player.bang_used and not (w != null and w.card_name == "Volcanic"):
				return false
			if target == null or not can_reach_target(game, player, target):
				return false

		if action_card.action == ActionCard.Action.DUEL:
			if target == null or target == player or not target.is_alive():
				return false

		if action_card.action == ActionCard.Action.PANIC:
			if target == null or target == player or not target.is_alive():
				return false
			if get_effective_distance(game, player, target) > 1:
				return false

		if action_card.action == ActionCard.Action.CAT_BALOU:
			if target == null or target == player or not target.is_alive():
				return false

	if card is PermanentCard:
		var permanent := card as PermanentCard

		if permanent.card_name == "Cárcel":
			if target == null or target == player or not target.is_alive():
				return false

			for existing in target.in_play.cards:
				if existing.card_name == "Cárcel":
					return false

			if target.role == null or target.role.card_name == "Sheriff":
				return false

	return true

static func resolve_card(game: Game, player: Player, card: Card, target: Player = null) -> void:
	if game == null or player == null or card == null:
		return
	
	match card.type:
		Card.CardType.ACTION:
			resolve_action_card(game, player, card as ActionCard, target)
		Card.CardType.WEAPON:
			resolve_weapon_card(game, player, card as WeaponCard)
		Card.CardType.PERMANENT:
			resolve_permanent_card(game, player, card as PermanentCard, target)

static func resolve_action_card(game: Game, player: Player, card: ActionCard, target: Player = null) -> void:

	match card.action:

		ActionCard.Action.BANG:
			resolve_bang(game, player, card, target)

		ActionCard.Action.BEER:
			resolve_beer(game, player, card)

		ActionCard.Action.SALOON:
			resolve_saloon(game, card)

		ActionCard.Action.DILIGENCE:
			resolve_diligence(game, player, card)

		ActionCard.Action.WELLS_FARGO:
			resolve_wells_fargo(game, player, card)

		ActionCard.Action.DUEL:
			resolve_duel(game, player, card, target)
		
		ActionCard.Action.GATLING:
			resolve_gatling(game, player, card)
		
		ActionCard.Action.INDIANS:
			resolve_indians(game, player, card)
		
		ActionCard.Action.PANIC:
			resolve_panic(game, player, card, target)
		
		ActionCard.Action.CAT_BALOU:
			resolve_cat_balou(game, player, card, target)
		
		ActionCard.Action.EMPORIUM:
			resolve_emporium(game, player, card)
		
		_:
			game.discard_card(card)

static func resolve_permanent_card(game: Game, player: Player, card: PermanentCard, target: Player = null) -> void:
	var owner: Player = player

	if card.card_name == "Cárcel":
		if target == null or target == player or not target.is_alive():
			push_error(
				"Rules.resolve_permanent_card(): 'Cárcel' necesita un objetivo válido."
			)
			game.discard_card(card)
			return
		owner = target

	for existing in owner.in_play.cards.duplicate():
		if existing.card_name == card.card_name:
			game.move_card(existing, game.discard_pile)
			break

	owner.in_play.add_card(card)

static func resolve_bang(game: Game, player: Player, card: ActionCard, target: Player) -> void:
	player.bang_used = true
	game.discard_card(card)

	if _player_has_in_play(target, "Barril"):
		if _barrel_saves(game, target):
			return 

	if has_missed_card(target):
		game.start_event(MissedEvent.new(game, player, target))
	else:
		deal_damage(game, target, player, 1)

static func resolve_beer(game: Game, player: Player, card: ActionCard) -> void:
	player.heal(1)
	game.discard_card(card)

static func resolve_saloon(game: Game, card: ActionCard) -> void:
	for player in game.players:
		player.heal(1)
	game.discard_card(card)

static func resolve_diligence(game: Game, player: Player, card: ActionCard) -> void:
	game.draw_cards(player, 2)
	game.discard_card(card)

static func resolve_wells_fargo(game: Game, player: Player, card: ActionCard) -> void:
	game.draw_cards(player, 3)
	game.discard_card(card)

static func resolve_missed(game: Game, player: Player, card: ActionCard) -> bool:
	game.discard_card(card)
	return true

static func resolve_duel(game: Game, player: Player, card: ActionCard, target: Player) -> void:
	game.discard_card(card)

	if target == null:
		push_error("Rules.resolve_duel(): objetivo nulo")
		return

	if has_bang_card(target):
		game.start_event(DuelEvent.new(game, player, target))
	else:
		deal_damage(game, target, player, 1)

static func resolve_gatling(game: Game, player: Player, card: ActionCard) -> void:
	game.discard_card(card)
	game.start_event(GatlingEvent.new(game, player))

static func resolve_indians(game: Game, player: Player, card: ActionCard) -> void:
	game.discard_card(card)
	game.start_event(IndiansEvent.new(game, player))

static func resolve_panic(game: Game, player: Player, card: ActionCard, target: Player) -> void:
	game.discard_card(card)

	if target == null or target == player or not target.is_alive():
		return

	if get_effective_distance(game, player, target) > 1:
		push_error("Rules.resolve_panic(): objetivo fuera de alcance")
		return

	if target.in_play.is_empty():
		if target.hand.is_empty():
			return
		var idx := randi() % target.hand.size()
		var taken: Card = target.hand.get_card(idx)
		game.move_card(taken, player.hand)
		return

	game.start_event(TakeCardEvent.new(game, player, target, player.hand))

static func resolve_cat_balou(game: Game, player: Player, card: ActionCard, target: Player) -> void:
	game.discard_card(card)

	if target == null or target == player or not target.is_alive():
		return

	if target.in_play.is_empty():
		if target.hand.is_empty():
			return
		var idx := randi() % target.hand.size()
		var taken: Card = target.hand.get_card(idx)
		game.move_card(taken, game.discard_pile)
		return

	game.start_event(TakeCardEvent.new(game, player, target, game.discard_pile))

static func resolve_emporium(game: Game, player: Player, card: ActionCard) -> void:
	game.discard_card(card)
	game.start_event(EmporiumEvent.new(game, player))

static func resolve_weapon_card(game: Game, player: Player, card: WeaponCard) -> void:
	var current_weapon := player.get_weapon()
	if current_weapon != null:
		game.move_card(current_weapon, game.discard_pile)
	game.move_card(card, player.in_play)

static func resolve_player_elimination(game: Game, victim: Player, killer: Player) -> void:
	if game == null or victim == null:
		push_error("Rules.resolve_player_elimination(): víctima nula.")
		return

	game.discard_player_cards(victim)

	if victim.role == null:
		return

	if killer == null or killer == victim:
		return

	if victim.role.card_name == "Outlaw" and killer.is_alive():
		game.draw_cards(killer, 3)

	if killer.role != null and killer.role.card_name == "Sheriff" and victim.role.card_name == "Deputy":
		game.discard_player_cards(killer)

static func deal_damage(game: Game, victim: Player, killer: Player, amount: int) -> void:
	if game == null or victim == null or amount <= 0:
		return
	if not victim.is_alive():
		return

	victim.take_damage(amount)

	if victim.health > 0:
		return

	var beers_needed := 1 - victim.health
	var beers_available := _count_beers(victim)

	if beers_available >= beers_needed:
		_play_beers(game, victim, beers_needed)
		return

	victim.is_dead = true
	resolve_player_elimination(game, victim, killer)
	game.check_victory()

static func get_distance(game: Game, source: Player, target: Player) -> int:
	if game == null or source == null or target == null or source == target:
		return 0

	var source_index := game.players.find(source)
	var target_index := game.players.find(target)

	if source_index == -1 or target_index == -1:
		push_error("Rules.get_distance(): jugador no encontrado en la partida")
		return 0

	var cw := _count_alive_to_target(game, source_index, target_index, 1)
	var ccw := _count_alive_to_target(game, source_index, target_index, -1)

	return mini(cw, ccw)

static func _count_alive_to_target(game: Game, from_index: int, to_index: int, step: int) -> int:
	var total := game.players.size()
	var count := 0
	var index := from_index

	for i in range(total):
		index = (index + step + total) % total
		if game.players[index].is_alive():
			count += 1
		if index == to_index:
			return count

	return total

static func has_missed_card(player: Player) -> bool:

	for card in player.hand.cards:
		if card is ActionCard:
			var action_card := card as ActionCard

			if action_card.action == ActionCard.Action.MISSED:
				return true

	return false

static func has_bang_card(player: Player) -> bool:
	if player == null:
		return false

	for card in player.hand.cards:
		if card is ActionCard:
			var action_card := card as ActionCard
			if action_card.action == ActionCard.Action.BANG:
				return true

	return false

static func can_reach_target(game: Game, source: Player, target: Player) -> bool:
	if source == null or target == null or source == target:
		return false
	if not source.is_alive() or not target.is_alive():
		return false

	return get_effective_distance(game, source, target) <= source.get_weapon_range()

static func _player_has_in_play(player: Player, card_name: String) -> bool:
	for card in player.in_play.cards:
		if card.card_name == card_name:
			return true
	return false

static func check_victory(game: Game) -> VictoryResult:
	if game == null:
		return VictoryResult.NONE

	var sheriff_alive: bool = false
	var outlaw_alive: bool = false
	var renegade_alive: bool = false
	var alive_count: int = 0

	for player in game.players:
		if not player.is_alive() or player.role == null:
			continue

		alive_count += 1

		match player.role.card_name:
			"Sheriff":
				sheriff_alive = true
			"Outlaw":
				outlaw_alive = true
			"Renegade":
				renegade_alive = true

	if not sheriff_alive:
		if alive_count == 1 and renegade_alive:
			return VictoryResult.RENEGADE
		return VictoryResult.OUTLAWS

	if not outlaw_alive and not renegade_alive:
		return VictoryResult.LAW

	return VictoryResult.NONE

static func _barrel_saves(game: Game, target: Player) -> bool:
	var pc := reveal_card(game)

	var is_hearts := (pc.suit == PlayingCard.Suit.HEARTS)
	return is_hearts

static func reveal_card(game: Game) -> PlayingCard:
	if game.game_deck.size() < 1:
		game.recycle_discard()
	if game.game_deck.size() == 0:
		return null
	var card: Card = game.game_deck.get_last_card()
	game.move_card(card, game.discard_pile)
	if card is PlayingCard:
		return card as PlayingCard
	return null

static func try_escape_jail(game: Game, player: Player) -> bool:
	var pc := reveal_card(game)
	var is_hearts := (pc.suit == PlayingCard.Suit.HEARTS)

	_discard_jail(game, player)
	return is_hearts


static func _discard_jail(game: Game, player: Player) -> void:
	for card in player.in_play.cards.duplicate():
		if card.card_name == "Cárcel":
			game.move_card(card, game.discard_pile)
			return

static func _count_beers(player: Player) -> int:
	var count := 0
	for card in player.hand.cards:
		if card is ActionCard and (card as ActionCard).action == ActionCard.Action.BEER:
			count += 1
	return count

static func _find_beer(player: Player) -> Card:
	for card in player.hand.cards:
		if card is ActionCard and (card as ActionCard).action == ActionCard.Action.BEER:
			return card
	return null

static func _play_beers(game: Game, player: Player, count: int) -> void:
	for i in range(count):
		var beer := _find_beer(player)
		if beer == null:
			break
		if not game.move_card(beer, game.discard_pile):
			break
		player.heal(1)

static func get_effective_distance(game: Game, source: Player, target: Player) -> int:
	if game == null or source == null or target == null or source == target:
		return 0

	var distance := get_distance(game, source, target)

	if _player_has_in_play(source, "Mira telescópica"):
		distance -= 1

	if _player_has_in_play(target, "Mustang"):
		distance += 1

	return maxi(distance, 1)
