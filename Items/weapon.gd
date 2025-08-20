extends Equipment
class_name Weapon

enum WeaponType {
	SWORD = 50,
	STAFF,
	AXE,
	DAGGER,
	MACE,
	BOW
}

enum HandType {
	ONE_HANDED,
	TWO_HANDED
}

enum WeaponStat {
	MIN_DMG,
	MAX_DMG,
	RANGE,
	BASE_CRIT,
	BASE_MULTIPLIER,
}

@export var weapon_type:WeaponType = WeaponType.AXE
@export var hand_type:HandType = HandType.ONE_HANDED
@export var scale_stat:Stats.MainStat = Stats.MainStat.MIGHT

@export var weapon_stats:Dictionary[WeaponStat,int] = {
	WeaponStat.MIN_DMG: 1,
	WeaponStat.MAX_DMG: 1,
	WeaponStat.RANGE: 1,
	WeaponStat.BASE_CRIT: 5,
	WeaponStat.BASE_MULTIPLIER: 100,
}
