from Weapon import *
from Character import *
from random import *
from Item import *

#Describes anything which is a non-friendly NPC
class Entity:
	def __init__(self, PlayerInfo):
		self.Name = "Entity"
		self.Weapon = Weapon()
		self.EXPValue = self.CalculateEXP([PlayerInfo.MaxHealth, PlayerInfo.Level])
		self.Description = ""

		self.MaxHealth = 10 + (PlayerInfo.MaxHealth + PlayerInfo.Level)
		self.CurrentHealth = self.MaxHealth

		self.ItemTable = [SlimeGoo(), None]

	def __str__(self):
		return self.Description + "\n" + self.Name + " Health: " + str(self.CurrentHealth) + "/" + str(self.MaxHealth)

	#Wants a list as the modifier value
	def CalculateEXP(self, Modifiers, Lower = 12, Upper = 30) -> int:
		EXP = randint(Lower, Upper)

		for i in Modifiers:
			EXP += int(i)

		return EXP

	def Attack(self, Player):
		if self.CurrentHealth > 0:
			Damage = self.Weapon.Attack(0)
			Player.CurrentHealth -= Damage
			print(Player.Name, "recieved ", Damage, "dmg")
			print(Player.Name, "has ", Player.CurrentHealth, "/", Player.MaxHealth)
			Player.Update()

	def TakeDamage(self, Damage):
		if self.CurrentHealth > 0:
			self.CurrentHealth -= Damage
			
			if self.CurrentHealth < 0:
				self.CurrentHealth = 0
				
			print("You dealt", Damage, "dmg")
			print(self.Name, "has", self.CurrentHealth, "/", self.MaxHealth)
		else:
			print("Nothing to attack")

	def Update(self, Player, Room):
		if self.CurrentHealth <= 0:
			self.Die(Player, Room)
			return None
		return self

	def Die(self, Player, Room):
		Player.Exp += self.EXPValue
		Room.DroppedItem = self.DropLoot()

		print(Player.Name, " has gained ", self.EXPValue, "EXP")

		if Room.DroppedItem != None:
			print(self.Name, " dropped ", Room.DroppedItem.ItemName)

	def DropLoot(self):
		return choice(self.ItemTable)

class Slime(Entity):
	def __init__(self, Player):
		Entity.__init__(self, Player)

		self.Name = "Slime"
		self.Weapon = SlimeAttack()
		self.Description = "A small neon-blue translucent gel like blob appears. Two large, round, eyes stare blankly at you."
		self.EXPValue = randint(15, 30)
