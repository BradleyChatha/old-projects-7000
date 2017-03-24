class Item:
	def __init__(self):
		self.ItemName = ""
		self.ItemDescription = ""
		self.CostValue = 100 #Buying from an NPC
		self.SaleValue = 75 #Selling to an NPC

	def __str__(self) -> str:
		return self.ItemName + " " + self.ItemDescription

	def OnUse(self, Player = None):
		pass
