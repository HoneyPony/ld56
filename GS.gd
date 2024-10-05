extends Node

# The "global state" node. This is where global variables are usually stored,
# as well as things like scene preloads.

var Game = preload("res://Game.tscn")
var MainMenu = preload("res://MainMenu.tscn")

var EnemyProjectile1 = preload("res://enemies/enemy_projectile1.tscn")
var EnemyProjectile1Particle = preload("res://enemies/enemy_projectile_1_particle.tscn")

var PlayerProjectile1 = preload("res://hazard/player_projectile1.tscn")

var BuffProjectile = preload("res://buffs/player_buff.tscn")
var SplitProjectile = preload("res://buffs/split_buff.tscn")

var Player = preload("res://players/player.tscn")

enum Item {
	Sword,
	Club,
	Dagger,
	Mace,
	Staff,
	Scythe
}

enum Class {
	Brawler,
	Mage,
	Cleric,
	Summoner
}

enum Buff {
	None,
	Shield,
	Dagger
}

var valid_imps = [
	[Class.Brawler, Item.Sword],
	[Class.Brawler, Item.Club],
	[Class.Brawler, Item.Dagger],
	[Class.Brawler, Item.Mace],
	[Class.Mage, Item.Staff],
	[Class.Mage, Item.Dagger],
	[Class.Cleric, Item.Staff],
	[Class.Cleric, Item.Sword],
	[Class.Cleric, Item.Scythe],
	[Class.Summoner, Item.Scythe],
]

func finish_spawn_imp(parent: Node, config: Array, global_pos: Vector2, damage_override: int):
	var imp = Player.instantiate()
	parent.add_child(imp)
	imp.global_position = global_pos
	imp.set_class(config[0])
	imp.set_item(config[1])
	imp.compute_basic_properties()
	imp.finalize_properties()
	if damage_override != -1:
		imp.set_own_damage(damage_override)

func spawn_imp(parent: Node, config: Array, global_pos: Vector2, damage_override: int = -1):
	call_deferred("finish_spawn_imp", parent, config, global_pos, damage_override)
	
	
	

func _ready():
	pass
