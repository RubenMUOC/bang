
extends Control

const PLAYER_PANEL_SCENE: PackedScene = preload(
    "res://Debug/player_panel.tscn"
)

@onready var game_info: Label = $MainLayout/GameInfo
@onready var players_container: VBoxContainer = \
	$MainLayout/PlayersScroll/PlayersContainer

@onready var start_game_button: Button = \
	$MainLayout/DebugControls/StartGameButton
@onready var play_card_button: Button = \
	$MainLayout/DebugControls/PlayCardButton
@onready var end_turn_button: Button = \
	$MainLayout/DebugControls/EndTurnButton
@onready var revealed_cards_container: HBoxContainer = \
	$MainLayout/RevealedCardsContainer
@onready var deck_list_label: Label = $MainLayout/DeckListLabel
@onready var discard_list_label: Label = $MainLayout/DiscardListLabel
@onready var discard_button: Button = null

var game: Game
var selected_card: Card = null
var selected_card_owner: Player = null
var selected_player: Player = null

func _ready() -> void:
	game = Game.new()

	var controls: HBoxContainer = \
		$MainLayout/DebugControls

	start_game_button.pressed.connect(_on_start_game_pressed)

	play_card_button = Button.new()
	play_card_button.text = "Jugar carta"
	controls.add_child(play_card_button)
	play_card_button.pressed.connect(_on_play_card_pressed)
	
	end_turn_button = Button.new()
	end_turn_button.text = "Pasar turno"
	controls.add_child(end_turn_button)
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	
	discard_button = Button.new()
	discard_button.text = "Descartar carta"
	controls.add_child(discard_button)
	discard_button.pressed.connect(_on_discard_pressed)
	
	_verify_layout.call_deferred()

func _verify_layout() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	
	_refresh_interface()

func _on_start_game_pressed() -> void:
	if game.game_state == game.GameState.PLAYING:
		push_error("Debug._on_start_game_pressed(): la partida ya esta iniciada")
		return

	for i in 7:
		var player: Player = game.add_player("Jugador %d" % (i + 1))

	if game.players.size() < 4 or game.players.size() > 7:
		push_error("Debug._on_start_game_pressed(): numero de jugadores invalido")
		return

	game.start_game()

	if not game.game_state == game.GameState.PLAYING:
		push_error("Debug._on_start_game_pressed(): no se pudo iniciar la partida")
		_refresh_interface()
		return

	start_game_button.disabled = true
	_refresh_interface()

func _refresh_interface() -> void:
	if game == null:
		push_error("Debug._refresh_interface(): no hay una partida")
		return

	if game.current_event != null:
		if game.current_event is MissedEvent or game.current_event is GatlingEvent:
			play_card_button.text = "Jugar ¡Fallaste!"
			play_card_button.disabled = false
			end_turn_button.text = "Aceptar daño"
			end_turn_button.disabled = false
		elif game.current_event is DuelEvent or game.current_event is IndiansEvent:
			play_card_button.text = "Jugar ¡Bang!"
			play_card_button.disabled = false
			end_turn_button.text = "No responder"
			end_turn_button.disabled = false
		elif game.current_event is TakeCardEvent:
			var pe := game.current_event as TakeCardEvent
			play_card_button.text = "Jugar carta"
			play_card_button.disabled = true
			if pe.has_hand_option():
				end_turn_button.text = "Robar de la mano (aleatorio)"
				end_turn_button.disabled = false
			else:
				end_turn_button.text = "Elige una carta de la mesa"
				end_turn_button.disabled = true
		elif game.current_event is EmporiumEvent:
			play_card_button.text = "Jugar carta"
			play_card_button.disabled = true
			end_turn_button.text = "Elige una carta del pool"
			end_turn_button.disabled = true
		else:
			play_card_button.text = "Jugar carta"
			play_card_button.disabled = false
			end_turn_button.text = "Resolver"
			end_turn_button.disabled = false
	else:
		play_card_button.text = "Jugar carta"
		play_card_button.disabled = false
		end_turn_button.text = "Pasar turno"
		end_turn_button.disabled = false

	var selection_text := "Sin selección"

	if selected_card != null:
		selection_text = "Carta: " + selected_card.card_name

	if selected_player != null:
		selection_text += " | Objetivo: " + selected_player.name

	game_info.text = (
		"Turno: %d | Jugadores: %d | Mazo: %d | Descartes: %d\n%s"
		% [
			game.turn_number,
			game.players.size(),
			game.game_deck.size(),
			game.discard_pile.size(),
			selection_text
		]
	)
	
	deck_list_label.text = "Mazo (%d): %s" % [
	game.game_deck.size(),
	_format_pile(game.game_deck, 15)
	]
	
	discard_list_label.text = "Descartes (%d): %s" % [
		game.discard_pile.size(),
		_format_pile(game.discard_pile, 15)
	]

	_clear_players()

	var active_player := game.get_active_player()

	var can_play := Callable()
	if game.current_event != null:
		if game.current_event is TakeCardEvent:
			var pe := game.current_event as TakeCardEvent
			can_play = func(p: Player, c: Card) -> bool:
				return p == pe.target and c.location == p.in_play
		elif game.current_event is EmporiumEvent:
			can_play = func(_p: Player, _c: Card) -> bool:
				return false
		else:
			can_play = func(p: Player, c: Card) -> bool:
				return game.current_event.can_play(p, c)

	_clear_children(revealed_cards_container)

	if game.current_event != null and game.current_event is EmporiumEvent:
		revealed_cards_container.visible = true
		var em := game.current_event as EmporiumEvent
		var actor := em.get_actor()
		for card in em.get_revealed().cards:
			var btn := Button.new()
			btn.text = card.card_name
			btn.custom_minimum_size = Vector2(100, 55)
			btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			btn.disabled = (actor == null)
			btn.pressed.connect(_on_revealed_card_selected.bind(card))
			revealed_cards_container.add_child(btn)
	else:
		revealed_cards_container.visible = false

	for i in range(game.players.size()):
		var player: Player = game.players[i]
		var panel := PLAYER_PANEL_SCENE.instantiate() as DebugPlayerPanel
		if panel == null:
			push_error("Debug._refresh_interface(): no se pudo crear el panel")
			continue

		players_container.add_child(panel)

		panel.card_selected.connect(_on_card_selected)
		panel.player_selected.connect(_on_player_selected)
		panel.in_play_card_selected.connect(_on_in_play_card_selected)

		panel.update_player(
			player,
			player == active_player,
			selected_card,
			can_play
		)
		
	discard_button.disabled = game.game_state == game.GameState.NOT_STARTED or game.current_event != null

func _on_card_selected(card: Card, owner: Player) -> void:
	selected_card = card
	selected_card_owner = owner
	_refresh_interface()

func _on_revealed_card_selected(card: Card) -> void:
	if game.current_event == null:
		return
	if game.current_event is not EmporiumEvent:
		return
	var actor := game.get_active_player()
	if actor == null:
		return
	game.play_card(actor, card)
	selected_card = null
	selected_card_owner = null
	selected_player = null
	_refresh_interface()

func _on_in_play_card_selected(card: Card, owner: Player) -> void:
	if game.current_event != null and game.current_event is TakeCardEvent:
		var pe := game.current_event as TakeCardEvent
		if pe.take_from_in_play(card):
			game.can_end_event()
			selected_card = null
			selected_card_owner = null
			selected_player = null
			_refresh_interface()
		return

	selected_card = card
	selected_card_owner = owner
	_refresh_interface()

func _on_player_selected(player: Player) -> void:
	if player == null:
		return

	if not player.is_alive():
		push_warning("Debug._on_player_selected(): No puedes seleccionar a un jugador eliminado")
		selected_player = null
		_refresh_interface()
		return

	selected_player = player
	_refresh_interface()

func _clear_players() -> void:
	_clear_children(players_container)

func _clear_children(container: Node) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

func _on_play_card_pressed() -> void:
	if not game.game_state == game.GameState.PLAYING:
		push_warning("Debug._on_play_card_pressed(): No existe game iniciado")
		return

	if game.current_event != null:
		if selected_card == null or selected_card_owner == null:
			push_warning("Debug._on_play_card_pressed(): No hay carta seleccionada")
			return

		if selected_card_owner != game.get_active_player():
			push_warning("Debug._on_play_card_pressed(): Solo el actor del evento puede responder")
			return

		if not game.play_card(selected_card_owner, selected_card):
			return

		selected_card = null
		selected_card_owner = null
		selected_player = null
		_refresh_interface()
		return

	var current_player: Player = game.get_current_player()

	if selected_card == null or selected_card_owner == null:
		push_warning("Debug._on_play_card_pressed(): Selecciona una carta de la mano")
		return

	if selected_card_owner != current_player:
		push_warning("Debug._on_play_card_pressed(): Solo puedes jugar cartas de tu propio turno")
		return

	if selected_card is ActionCard:
		var action_card := selected_card as ActionCard
		
		if selected_card_owner != null and not selected_card_owner.hand.has_card(selected_card):
			push_warning("Debug._on_play_card_pressed(): Solo puedes jugar cartas de la mano")
			return

		match action_card.action:
			ActionCard.Action.BANG:
				if current_player.bang_used and not (current_player.get_weapon() != null and current_player.get_weapon().card_name == "Volcanic"):
					push_warning("Debug._on_play_card_pressed(): Ya has usado BANG! este turno")
					return

				if selected_player == null:
					push_warning("Debug._on_play_card_pressed(): Selecciona un jugador objetivo para el Bang")
					return

				if not Rules.can_reach_target(
					game, current_player, selected_player
				):
					push_warning("Debug._on_play_card_pressed(): El objetivo no es valido o está fuera de alcance")
					return

				if not game.play_card(
					current_player, selected_card, selected_player
				):
					return

			ActionCard.Action.BEER:
				if current_player.is_dead:
					return

				if current_player.health >= current_player.max_health:
					push_warning("Debug._on_play_card_pressed(): Vida maxima alcanzada")
					return

				if not game.play_card(current_player, selected_card):
					return

			ActionCard.Action.SALOON:
				if current_player.is_dead:
					return

				if not game.play_card(current_player, selected_card):
					return

			ActionCard.Action.DILIGENCE:
				if current_player.is_dead:
					return

				if not game.play_card(current_player, selected_card):
					return

			ActionCard.Action.WELLS_FARGO:
				if current_player.is_dead:
					return

				if not game.play_card(current_player, selected_card):
					return

			ActionCard.Action.DUEL:
				if selected_player == null:
					push_warning("Debug._on_play_card_pressed(): Selecciona un jugador objetivo para el duelo")
					return

				if selected_player == current_player:
					push_warning("Debug._on_play_card_pressed(): No puedes usar duelo sobre ti mismo")
					return

				if not selected_player.is_alive():
					push_warning("Debug._on_play_card_pressed(): El objetivo del duelo esta eliminado")
					return

				if not game.play_card(current_player, selected_card, selected_player):
					return
			
			ActionCard.Action.GATLING:
				if not game.play_card(current_player, selected_card):
					return
			
			ActionCard.Action.INDIANS:
				if not game.play_card(current_player, selected_card):
					return
			
			ActionCard.Action.PANIC:
				if selected_player == null:
					push_warning("Debug._on_play_card_pressed(): Selecciona un jugador objetivo para Panico")
					return
				if selected_player == current_player:
					push_warning("Debug._on_play_card_pressed(): No puedes usar Panico sobre ti mismo")
					return
				if not selected_player.is_alive():
					push_warning("Debug._on_play_card_pressed(): El objetivo de Panico está eliminado")
					return
				if not game.play_card(current_player, selected_card, selected_player):
					return
			
			ActionCard.Action.CAT_BALOU:
				if selected_player == null:
					push_warning("Debug._on_play_card_pressed(): Selecciona un jugador objetivo para Cat Balou")
					return
				if selected_player == current_player:
					push_warning("Debug._on_play_card_pressed(): No puedes usar Cat Balou sobre ti mismo")
					return
				if not selected_player.is_alive():
					push_warning("Debug._on_play_card_pressed(): El objetivo de Cat Balou esta eliminado")
					return
				if not game.play_card(current_player, selected_card, selected_player):
					return
			
			ActionCard.Action.EMPORIUM:
				if not game.play_card(current_player, selected_card):
					return
			
			_:
				push_warning("Debug._on_play_card_pressed(): Carta no implementada")
				return

	elif selected_card is WeaponCard:
		if not game.play_card(current_player, selected_card):
			return

	elif selected_card is PermanentCard:
		var permanent := selected_card as PermanentCard
		if permanent.card_name == "Cárcel":
			if selected_player == null:
				push_warning("Debug._on_play_card_pressed(): Selecciona un jugador objetivo para Carcel")
				return
			if selected_player == current_player:
				push_warning("Debug._on_play_card_pressed(): No puedes encarcelarte a ti mismo")
				return
			if not selected_player.is_alive():
				push_warning("Debug._on_play_card_pressed(): El objetivo de Carcel esta eliminado")
				return
			if selected_player.role != null and selected_player.role.card_name == "Sheriff":
				push_warning("Debug._on_play_card_pressed(): No puedes encarcelar al Sheriff")
				return

		if not game.play_card(current_player, selected_card, selected_player):
			return

	else:
		push_warning("Debug._on_play_card_pressed(): carta no implementada")
		return

	selected_card = null
	selected_card_owner = null
	selected_player = null
	_refresh_interface()

func _on_end_turn_pressed() -> void:
	if not game.game_state == game.GameState.PLAYING:
		push_warning("Debug._on_end_turn_pressed(): No hay game iniciado")
		return

	if game.current_event != null:
		game.pass_event()

		selected_card = null
		selected_card_owner = null
		selected_player = null
		_refresh_interface()
		return

	game.end_turn()

	selected_card = null
	selected_card_owner = null
	selected_player = null
	_refresh_interface()

func _format_pile(pile: Deck, max_cards: int = -1) -> String:
	if pile.is_empty():
		return "(vacío)"

	var cards := pile.cards.duplicate()
	cards.reverse()

	var limit := cards.size() if max_cards <= 0 else mini(max_cards, cards.size())

	var names: Array[String] = []
	for i in range(limit):
		names.append(cards[i].card_name)

	var text := ", ".join(names)

	if limit < cards.size():
		text += " ... (+%d)" % (cards.size() - limit)

	return text

func _on_discard_pressed() -> void:
	if not game.game_state == game.GameState.PLAYING:
		push_warning("Debug._on_discard_pressed(): No hay game iniciado")
		return

	if game.current_event != null:
		push_warning("Debug._on_discard_pressed(): No puedes descartar durante un evento")
		return

	if selected_card == null or selected_card_owner == null:
		push_warning("Debug._on_discard_pressed(): Selecciona una carta para descartar")
		return

	var current := game.get_current_player()
	if current == null or not current.is_alive():
		push_warning("Debug._on_discard_pressed(): Jugador no valido")
		return

	if selected_card_owner != current:
		push_warning("Debug._on_discard_pressed(): Solo puedes descartar cartas del jugador actual")
		return

	if selected_card_owner.in_play.has_card(selected_card):
		if selected_card.card_name == "Dinamita" or selected_card.card_name == "Cárcel":
			push_warning("No puedes descartar '%s' manualmente desde la mesa." % selected_card.card_name)
			return

	var card_name := selected_card.card_name
	game.move_card(selected_card, game.discard_pile)

	selected_card = null
	selected_card_owner = null
	selected_player = null
	_refresh_interface()
