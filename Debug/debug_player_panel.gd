
class_name DebugPlayerPanel
extends PanelContainer

signal card_selected(card: Card, owner: Player)
signal player_selected(player: Player)
signal in_play_card_selected(card: Card, owner: Player)

@onready var player_info: Label = $Content/PlayerInfo
@onready var health_info: Label = $Content/HealthInfo
@onready var weapon_info: Label = $Content/WeaponInfo
@onready var table_cards: HBoxContainer = $Content/TableCards
@onready var hand_cards: HBoxContainer = $Content/HandCards

var displayed_player: Player
var selected_card: Card

func _ready() -> void:
	player_info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	health_info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	weapon_info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	table_cards.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hand_cards.mouse_filter = Control.MOUSE_FILTER_IGNORE

func update_player(
	player: Player,
	is_current: bool,
	current_selection: Card = null,
	can_play_card: Callable = Callable()
) -> void:
	if player == null:
		push_error("DebugPlayerPanel: jugador nulo.")
		return

	displayed_player = player
	selected_card = current_selection

	var turn_text := "  <-- TURNO ACTUAL" if is_current else ""

	var role_name := "Sin rol"
	if player.role != null:
		role_name = player.role.card_name

	var character_name := "Sin personaje"
	if player.character != null:
		character_name = player.character.card_name

	player_info.text = "%s%s\nRol: %s | Personaje: %s" % [
		player.name,
		turn_text,
		role_name,
		character_name
	]

	health_info.text = "Vida: %d / %d | Estado: %s" % [
		player.health,
		player.max_health,
		"Muerto" if player.is_dead else "Vivo"
	]

	var w := player.get_weapon()
	if w == null:
		weapon_info.text = "Arma: Ninguna"
	else:
		weapon_info.text = "Arma: %s (alcance %d)" % [w.card_name, w.range]

	_refresh_cards(table_cards, player.in_play, player, can_play_card, false)
	_refresh_cards(hand_cards, player.hand, player, can_play_card, true)

func _refresh_cards(
	container: HBoxContainer,
	pile: Deck,
	owner: Player,
	can_play_card: Callable = Callable(),
	is_hand: bool = true
) -> void:
	_clear_container(container)

	for card in pile.cards:
		if card == null:
			continue

		var card_button := Button.new()
		card_button.text = card.card_name
		card_button.custom_minimum_size = Vector2(100, 55)
		card_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		card_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card_button.toggle_mode = true
		card_button.button_pressed = card == selected_card

		if can_play_card.is_valid():
			card_button.disabled = not can_play_card.call(owner, card)

		card_button.add_theme_stylebox_override(
			"normal",
			_create_card_style(
				card,
				Color("#e3c98b") if card == selected_card else Color("433c20ff")
			)
		)
		card_button.add_theme_stylebox_override(
			"hover",
			_create_card_style(card, Color("000000ff"))
		)
		card_button.add_theme_stylebox_override(
			"pressed",
			_create_card_style(card, Color("151515ff"))
		)

		card_button.pressed.connect(
			_on_card_button_pressed.bind(card, owner, is_hand)
		)

		container.add_child(card_button)

func _on_card_button_pressed(card: Card, owner: Player, is_hand: bool) -> void:
	if is_hand:
		card_selected.emit(card, owner)
	else:
		in_play_card_selected.emit(card, owner)

func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return

	if event.button_index != MOUSE_BUTTON_LEFT or not event.pressed:
		return

	if displayed_player == null or not displayed_player.is_alive():
		return

	player_selected.emit(displayed_player)
	accept_event()

func _clear_container(container: HBoxContainer) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

func _create_card_style(card: Card, bg_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.border_color = _get_card_type_color(card)
	style.bg_color = bg_color
	style.set_border_width_all(2)
	style.set_corner_radius_all(5)
	style.content_margin_left = 5
	style.content_margin_right = 5
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	return style

func _get_card_type_color(card: Card) -> Color:
	match card.type:
		Card.CardType.ACTION:
			return Color("ebb41aff")
		Card.CardType.WEAPON:
			return Color("2c80d1ff")
		Card.CardType.PERMANENT:
			return Color("#2c80d1ff")
		_:
			return Color("#817c70")
