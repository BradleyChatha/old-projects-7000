from random import *
from Weapon import *
from sys import *
from Inventory import *

class Character:
	def __init__(self, Name : str):
		self.Name = Name
		self.Level = 1
		self.Exp = 0
		self.NeededExp = 0
		self.NeededExp = self.CalculateEXP()

		self.Bag = Inventory()

		self.MaxHealth = 35
		self.CurrentHealth = self.MaxHealth

		self.MaxStamina = 20
		self.CurrentStamina = self.MaxStamina

		self.Strength = 5
		self.Intelligence = 5
		self.Will = 5

		self.PlayerWeapon = ShortSword()

		print(self)

	def __str__(self):
		Message = "\nName: " + self.Name + "\n"
		Message += "Level: " + str(self.Level) + "\n"
		Message += "Health: " + str(self.CurrentHealth) + "/" + str(self.MaxHealth) + "\n"
		Message += "Stamina: " + str(self.CurrentStamina) + "/" + str(self.MaxStamina) + "\n"
		Message += str(self.NeededExp - self.Exp) + " EXP to next level\n"
		Message += str(self.PlayerWeapon) + "\n"

		Message += "\n----- Stats ----\n"
		Message += "Strength: " + str(self.Strength) + "\n"
		Message += "Intelligence: " + str(self.Intelligence) + "\n"
		Message += "Will: " + str(self.Will) + "\n"
		return Message

	#Levels up the player.
	#Iterates until the player has entered a valid input for what stat they would like to level.
	def LevelUp(self, StatToLevel : int = None, ForceLevel = False):
		if self.Exp >= self.NeededExp or ForceLevel:
			self.MaxHealth += randint(10, 15)
			self.MaxStamina += randint(5, 10)
			self.Level += 1

			if StatToLevel == None:
				print("1) Strength")
				print("2) Intelligence")
				print("3) Will")
				StatToLevel = int(input("Enter a stat (1 - 3): "))

			while True:
				if StatToLevel == 1:
					self.Strength += 1
					break
				elif StatToLevel == 2:
					self.Intelligence += 1
					break
				elif StatToLevel == 3:
					self.Will += 1
					break

				print("1) Strength")
				print("2) Intelligence")
				print("3) Will")
				StatToLevel = int(input("Enter a valid stat (1 - 3): "))

			print("Level up!")
			print(self)

	def CalculateEXP(self) -> int:
		return (self.Level + (self.NeededExp + 15)) + randint(10, 50)

	def Update(self):
		if self.CurrentHealth <= 0:
			self.Die()
			return

	def Attack(self):
		return self.PlayerWeapon.Attack(self.Strength)

	def Heal(self, Amount : int):
		self.CurrentHealth += Amount

		if self.CurrentHealth > self.MaxHealth:
			self.CurrentHealth = self.MaxHealth

		print(self.Name, " has healed for ", Amount)
		print(self.Name, " now has ", str(self.CurrentHealth) + "/" + str(self.MaxHealth))

	def Die(self):
		print("You have died.")
		exit()