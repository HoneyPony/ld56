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

var nav: AStarGrid2D = AStarGrid2D.new()

func get_nav_point(global_pos: Vector2) -> Vector2i:
	global_pos -= Vector2(64, 64)
	var point = Vector2i((global_pos / 128.0).round())
	#point -= nav.region.position
	#print(point)
	return point
	
func get_nav_move_target(global_pos: Vector2, move_target: Vector2) -> Vector2:
	var from_point = GS.get_nav_point(global_pos)
	var to_point = GS.get_nav_point(move_target)
	
	# Only try to navigate if the target isn't on the same tile.
	if from_point != to_point:
		# Can't navigate if we don't have both points in the rectangle.
		# (We get many errors in the console and a 0-length nav array to boot).
		if not GS.nav.region.has_point(from_point):
			return move_target
		if not GS.nav.region.has_point(to_point):
			return move_target
		var move_target_nav = GS.nav.get_id_path(from_point, to_point, true)
		if move_target_nav.size() >= 2:
			var p1 = GS.nav.get_point_position(move_target_nav[1])
			var good_move_target = p1 + Vector2(64, 64)
			
			# If the move target and good_move_target are in a similar direction,
			# mostly use the existing move_target.
			
			var d0 = (good_move_target - global_pos).normalized()
			var d1 = (move_target - global_pos).normalized()
			# Exaggerate the nav weight to some degree.
			var good_weight = (1.0 - d0.dot(d1)) * 5.0
			good_weight = clamp(good_weight, 0, 1)
			move_target = lerp(move_target, good_move_target, good_weight)

	return move_target

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
	Dagger,
	Split,
	Ethereal,
}

var valid_imps = [
	[Class.Brawler, Item.Sword, "Brawler wielding Sword:\n- Attacks at 100% speed for 2 Melee damage."],
	[Class.Brawler, Item.Club, "Brawler wielding Club:\n- Attacks at 50% speed for 3 Melee damage."],
	[Class.Brawler, Item.Dagger, "Brawler wielding Dagger:\n- Attacks at 200% speed for 1 Melee damage."],
	[Class.Brawler, Item.Mace, "Brawler wielding Mace:\n- Attacks at 100% speed for 5 Melee damage.\n- Can only attack when enemies are below half health."],
	[Class.Mage, Item.Staff, "Mage wielding Staff:\n- Attacks at 100% speed for 1 Melee damage."],
	[Class.Mage, Item.Dagger, "Mage wielding Dagger:\n- Applies Strength buff to other imps.\n- Strength adds 1 damage to the next attack."],
	[Class.Mage, Item.Club, "Mage wielding Club:\n- Attacks at 100% speed for 0-4 Ranged damage.\n- Damage is rolled randomly."],
	[Class.Mage, Item.Scythe, "Mage wielding Scythe:\n- Attacks at 100% speed for 1 Ranged damage.\n- Shoots 5 shots in random directions."],
	[Class.Cleric, Item.Staff, "Cleric wielding Staff:\n- Applies Shield buff to nearby imps.\n- Shield buff blocks 1 hit from enemies."],
	[Class.Cleric, Item.Sword, "Cleric wielding Sword:\n- Attacks at 75% speed for 1 damage.\n- On kill, increase damage by 1 (resets next level)"],
	[Class.Cleric, Item.Scythe, "Cleric wielding Scythe:\n- Applies Split buff to nearby imps\n- Split imps do 1 fewer damage and cannot be further split."],
	[Class.Summoner, Item.Staff, "Summoner wielding Staff:\n- Summons random Ethereal imps.\n- Ethereal imps disappear after 4 seconds."],
	[Class.Summoner, Item.Scythe, "Summoner wielding Scythe:\n- Resurrects dead imps."],
]

var combat_imps = [
	0,
	1,
	2,
	3,
	4,
	# 5
	6,
	7,
	8,
	# 9 [cleric staff]
	10,
	# 11 [cleric splitter]
	# 12 might become another cleric
	#12, [ sumoners ]
	#13
]

func finish_spawn_imp(parent: Node, config: Array, global_pos: Vector2, split: bool, ethereal: bool):
	var imp = Player.instantiate()
	parent.add_child(imp)
	imp.global_position = global_pos
	imp.set_class(config[0])
	imp.set_item(config[1])
	imp.compute_basic_properties()
	imp.finalize_properties()
	if split:
		imp.add_buff(GS.Buff.Split)
	if ethereal:
		imp.add_buff(GS.Buff.Ethereal)

func spawn_imp(parent: Node, config: Array, global_pos: Vector2, split: bool = false, ethereal: bool = false):
	call_deferred("finish_spawn_imp", parent, config, global_pos, split, ethereal)
	
func get_item_tex(item: Item):
	var tex = null
	match item:
		GS.Item.Sword:
			tex = preload("res://players/sword.png")
		GS.Item.Staff:
			tex = preload("res://players/staff.png")
		GS.Item.Scythe:
			tex = preload("res://players/scythe.png")
		GS.Item.Dagger:
			tex = preload("res://players/dagger.png")
		GS.Item.Mace:
			tex = preload("res://players/mace.png")
		GS.Item.Club:
			tex = preload("res://players/club.png")
		_:
			print("Oops, we don't support that item yet")
	return tex
	
func get_body_tex(klass: Class):
	var tex = null
	match klass:
		GS.Class.Brawler:
			tex = preload("res://players/body0.png")
		GS.Class.Mage:
			tex = preload("res://players/body1.png")
		GS.Class.Cleric:
			tex = preload("res://players/body2.png")
		GS.Class.Summoner:
			tex = preload("res://players/body3.png")
		_:
			print("Oops, we don't support that class yet")
	return tex
	#
#func _process(delta):
	#print(get_nav_point($"/root/Game".get_global_mouse_position()))

func _ready():
	pass
