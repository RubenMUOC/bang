
class_name Player
extends RefCounted

var name: String
var role: RoleCard
var character: CharacterCard

var max_health: int = 0
var health: int = 0
var is_dead: bool = false

var hand: Hand = Hand.new()
var in_play: InPlay = InPlay.new()

var bang_used: bool = false

func _init(name: String):
	self.name = name

#func set_role

func set_character(character: CharacterCard) -> void:
	if character == null:
		return

	self.character = character
	max_health = character.health
	if role != null and role.card_name == "Sheriff":
		max_health += 1
	health = max_health
	is_dead = false

func take_damage(amount: int) -> void:
	if amount <= 0 or is_dead:
		return
	health -= amount

func heal(amount: int) -> void:
	if amount <= 0 or is_dead:
		return

	health += amount
	health = mini(health, max_health)


func get_weapon() -> WeaponCard:
	for card in in_play.cards:
		if card is WeaponCard:
			return card as WeaponCard
	return null

func get_weapon_range() -> int:
	var w := get_weapon()
	return w.range if w != null else 1

func hand_size() -> int:
	return hand.size()

func is_alive() -> bool:
	return not is_dead
