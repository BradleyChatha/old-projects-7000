from random import *

class Weapon:
	def __init__(self):
		self.WeaponName = "Fists"
		self.WeaponDamageLower = 1 #The lower amount of damage dealt
		self.WeaponDamageUpper = 3 #The upper amount of damage dealt

	def __str__(self):
		return "Equipped: " + self.WeaponName

	def Attack(self, PlayerStat) -> int:
		return randint(self.WeaponDamageLower, self.WeaponDamageUpper) + PlayerStat

class ShortSword(Weapon):
	def __init__(self):
		self.WeaponName = "Short Sword"
		self.WeaponDamageLower = 5
		self.WeaponDamageUpper = 15

#--- Mob Weapons ---
class SlimeAttack(Weapon):
	def __init__(self):
		self.WeaponName = "Slime bounce"
		self.WeaponDamageLower = 5
		self.WeaponDamageUpper = 6