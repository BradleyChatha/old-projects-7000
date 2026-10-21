from random import *

class Item:
	def __init__(self):
		self.ItemName = ""
		self.ItemDescription = ""
		self.CostValue = 100 #Buying from an NPC
		self.SaleValue = 75 #Selling to an NPC

	def __str__(self) -> str:
		return self.ItemName + "\n" + self.ItemDescription

	def OnUse(self, Player = None, Enemy = None):
		pass


class SlimeGoo(Item):
	def __init__(self):
		self.ItemName = "Slime Goo"
		self.ItemDescription = "A sticky neon-blue blob of goo"
		self.CostValue = 15
		self.SaleValue = 5

	def OnUse(self, Player = None, Enemy = None):
		Player.Heal(randint(1, 3))