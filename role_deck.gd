class_name RoleDeck
extends Deck

func _init():
	pass

func configure_for_player_count(player_count: int) -> bool:
	if player_count < 4 or player_count > 7:
		push_error("RoleDeck.configure_for_player_count(): numero de jugadores debe estar entre 4 y 7")
		return false

	cards.clear()
	
	add_card(RoleCard.new("Sheriff"))
	add_card(RoleCard.new("Renegade"))

	match player_count:
		4:
			add_card(RoleCard.new("Outlaw"))
			add_card(RoleCard.new("Outlaw"))
		5:
			add_card(RoleCard.new("Deputy"))
			add_card(RoleCard.new("Outlaw"))
			add_card(RoleCard.new("Outlaw"))
		6:
			add_card(RoleCard.new("Deputy"))
			add_card(RoleCard.new("Outlaw"))
			add_card(RoleCard.new("Outlaw"))
			add_card(RoleCard.new("Outlaw"))
		7:
			add_card(RoleCard.new("Deputy"))
			add_card(RoleCard.new("Deputy"))
			add_card(RoleCard.new("Outlaw"))
			add_card(RoleCard.new("Outlaw"))
			add_card(RoleCard.new("Outlaw"))

	shuffle()
	return true
