class_name Event
extends RefCounted

var game: Game
var finished: bool = false

func _init(p_game: Game) -> void:
	game = p_game

func get_actor() -> Player:
	return null

func can_play(player: Player, card: Card) -> bool:
	return false

func play_card(player: Player, card: Card) -> bool:
	return false

func can_skip(_player: Player) -> bool:
	return true

func skip(player: Player) -> void:
	pass

func is_finished() -> bool:
	return finished

func on_finish() -> void:
	pass
