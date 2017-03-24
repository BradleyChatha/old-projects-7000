from Character import *

#Describes any friendly NPC
class NPC:
	def __init__(self):
		self.Name = "Default NPC"
		self.Role = "Nothing"

	def __str__(self):
		return self.Name + ". Is a " + self.Role

	def OnInteraction(self, Player):
		pass

class Merchant(NPC):
	def __init__(self, Name):
		NPC.__init__(self)

		self.Name = Name
		self.Role = "merchant"

		#Todo: fill with items. Make item class, and inventory class
		Inventory = []