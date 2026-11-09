class_name Game
extends RefCounted

var role_deck: RoleDeck
var character_deck: CharacterDeck
var game_deck: GameDeck
var discard_pile: DiscardPile = DiscardPile.new()

var players: Array[Player] = []
var current_player_index: int = 0

enum GameState {
	NOT_STARTED,
	PLAYING,
	FINISHED
}
var game_state: GameState = GameState.NOT_STARTED

var turn_number: int = 0

var winner: Rules.VictoryResult = Rules.VictoryResult.NONE

var current_event: Event = null

func _init():
	role_deck = RoleDeck.new()
	character_deck = CharacterDeck.new()
	game_deck = GameDeck.new()

func add_player(player_name: String) -> Player:
	if not game_state == GameState.NOT_STARTED:
		push_error("Game.add_player(): la partida ya ha comenzado.")
		return null

	if players.size() >= 7:
		push_error("Game.add_player(): max 7 jugadores")
		return null

	var player := Player.new(player_name)
	players.append(player)

	return player

func start_game() -> void:
	if game_state == GameState.PLAYING:
		push_error("Game.start_game(): ya existe un game en curso")
		return
	
	if players.size() < 4 or players.size() > 7:
		push_error("Game.start_game(): numero invalido de players")
		return

	if not role_deck.configure_for_player_count(players.size()):
		push_error("Game.start_game(): no se pudo configurar el mazo de roles")
		return

	deal_roles()
	deal_characters()
	deal_initial_cards()

	var sheriff_index := get_sheriff_index()
	if sheriff_index == -1:
		push_error("Game.start_game(): no se ha encontrado al Sheriff")
		return
	current_player_index = sheriff_index

	turn_number = 1
	game_state = GameState.PLAYING

	start_turn()

func deal_roles() -> void:
	for player in players:
		player.role = role_deck.draw()

func deal_characters() -> void:
	for player in players:
		player.set_character(character_deck.draw())

func deal_initial_cards() -> void:
	for player in players:
		draw_cards(player, player.max_health)

func start_turn() -> void:
	if not game_state == GameState.PLAYING:
		return

	var player := get_current_player()
	if player == null or not player.is_alive():
		return

	if player_has_in_play(player, "Dinamita"):
		if not _resolve_dynamite(player):
			end_turn()
			return

	if player_has_in_play(player, "Cárcel"):
		var escaped := Rules.try_escape_jail(self, player)
		if not escaped:
			end_turn()
			return

	draw_cards(player, 2)

func end_turn() -> void:
	if not game_state == GameState.PLAYING:
		push_error("Game.end_turn(): no existe una partida iniciada")
		return
	
	var player := get_current_player()

	if player != null and player.is_alive():
		discard_excess_cards(player)
		player.bang_used = false

	next_player()

func next_player() -> void:
	if game_state == GameState.FINISHED:
		return

	if players.is_empty():
		push_error("Game.next_player(): no hay jugadores")
		return

	var players_checked := 0

	while players_checked < players.size():
		current_player_index += 1

		if current_player_index >= players.size():
			current_player_index = 0
			turn_number += 1

		players_checked += 1

		var next := players[current_player_index]

		if next.is_alive():
			start_turn()
			return

	push_warning("Game.next_player(): no quedan jugadores vivos para continuar la partida.")

func player_has_in_play(player: Player, card_name: String) -> bool:
	if player == null:
		return false
	for card in player.in_play.cards:
		if card.card_name == card_name:
			return true
	return false
	
func draw_cards(player: Player, amount: int) -> void:
	if player == null or amount <= 0:
		return

	if game_deck.size() < amount:
		recycle_discard()

	if game_deck.is_empty():
		push_warning("Game.draw_cards(): no quedan cartas en el mazo")
		return

	var drawn := 0
	while drawn < amount:
		var card := game_deck.get_last_card()
		if card == null:
			break
		if not move_card(card, player.hand):
			break
		drawn += 1

	if drawn < amount:
		push_warning("Game.draw_cards(): no se pudieron robar todas las catas")

func discard_excess_cards(player: Player) -> void:
	if player == null:
		return
	while player.hand.size() > player.health:
		var card: Card = player.hand.get_last_card()

		if card == null:
			push_error("Game.discard_excess_cards(): no se pudo obtener la carta")
			return

		if not player.hand.remove_card(card):
			push_error("Game.discard_excess_cards(): no se pudo retirar la carta de la mano")
			return

		discard_card(card)

func move_card(card: Card, destination: Deck) -> bool:
	if card == null or destination == null:
		push_error("Game.move_card(): carta o destino nulos")
		return false

	if card.location == destination:
		return true

	if card.location != null:
		if not card.location.has_card(card):
			push_error(
				"Game.move_card(): carta no existente en la localizacion")
			return false
		if not card.location.remove_card(card):
			push_error("Game.move_card(): no se pudo retirar la carta de su origen")
			return false

	destination.add_card(card)
	return true

func discard_card(card: Card) -> void:
	if card == null:
		push_error("Game.discard_card(): no existe carta para descartar")
		return
	move_card(card, discard_pile)

func discard_player_cards(player: Player) -> void:
	if player == null:
		return

	discard_player_hand_cards(player)
	discard_player_in_play_cards(player)

func discard_player_hand_cards(player: Player) -> void:
	while player.hand.size() > 0:
		var card: Card = player.hand.get_last_card()
		if card == null:
			break
		player.hand.remove_card(card)
		discard_card(card)

func discard_player_in_play_cards(player: Player) -> void:
	for card in player.in_play.cards.duplicate():
		discard_card(card)

	player.in_play.clear()

func recycle_discard() -> void:
	for card in discard_pile.cards.duplicate():
		move_card(card, game_deck)
	game_deck.shuffle()

func play_card(player: Player, card: Card, target: Player = null) -> bool:
	if current_event != null:
		var ok := current_event.play_card(player, card)
		if ok:
			can_end_event()
		return ok

	if not Rules.can_play_card(self, player, card, target):
		return false

	if not player.hand.remove_card(card):
		push_error("Game.play_card(): no se pudo retirar la carta de la mano del jugador")
		return false

	Rules.resolve_card(self, player, card, target)
	return true

func start_event(event: Event) -> bool:
	if event == null:
		push_error("Game.start_event(): evento nulo")
		return false
	if current_event != null:
		push_error("Game.start_event(): ya hay un evento activo")
		return false
	current_event = event
	can_end_event()
	return true

func pass_event() -> void:
	if current_event == null:
		return

	var actor := current_event.get_actor()
	if actor == null:
		return

	if not current_event.can_skip(actor):
		return

	current_event.skip(actor)
	can_end_event()

func can_end_event() -> void:
	if current_event == null or not current_event.is_finished():
		return

	current_event.on_finish()
	current_event = null

func get_active_player() -> Player:
	if current_event != null:
		return current_event.get_actor()
	return get_current_player()

func get_current_player() -> Player:
	if players.is_empty():
		push_error("Game.get_current_player(): no existen jugadores")
		return null

	return players[current_player_index]

func get_sheriff_index() -> int:
	for i in range(players.size()):
		var player := players[i]
		if player.role != null and player.role.card_name == "Sheriff":
			return i

	return -1

func check_victory() -> void:

	var result: Rules.VictoryResult = Rules.check_victory(self)

	if result == Rules.VictoryResult.NONE:
		return

	game_state = GameState.FINISHED
	winner = result

	match winner:
		Rules.VictoryResult.LAW:
			print("¡Victoria de la Ley!")
		Rules.VictoryResult.OUTLAWS:
			print("¡Victoria de los Forajidos!")
		Rules.VictoryResult.RENEGADE:
			print("¡Victoria del Renegado!")

func _get_next_alive_player(from: Player) -> Player:
	var start := players.find(from)
	if start == -1:
		return null
	var n := players.size()
	for offset in range(1, n):
		var p := players[(start + offset) % n]
		if p.is_alive() and p != from:
			return p
	return null

func _get_dynamite(player: Player) -> Card:
	for card in player.in_play.cards:
		if card.card_name == "Dinamita":
			return card
	return null

func _discard_dynamite(player: Player) -> void:
	var d := _get_dynamite(player)
	if d != null:
		move_card(d, discard_pile)

func _pass_dynamite(player: Player) -> void:
	var d := _get_dynamite(player)
	if d == null:
		return
	var next := _get_next_alive_player(player)
	if next == null:
		push_warning("Game._pass_dynamite(): no hay otro jugador vivo. Se descarta")
		move_card(d, discard_pile)
		return
	move_card(d, next.in_play)

func _resolve_dynamite(player: Player) -> bool:
	var pc := Rules.reveal_card(self)
	if pc == null:
		push_warning("Game._resolve_dynamite(): no hay cartas para revelar. Se considera que no explota.")
		_pass_dynamite(player)
		return true

	var explodes := (pc.suit == PlayingCard.Suit.SPADES and pc.value >= 2 and pc.value <= 9)

	if explodes:
		_discard_dynamite(player)
		Rules.deal_damage(self, player, null, 3)
		return player.is_alive()

	_pass_dynamite(player)
	return true
