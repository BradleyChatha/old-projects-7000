from Item import *

class Inventory:
	def __init__(self):
		self.Contents = []
		self.InvetorySpace = 10

		for i in range(0, self.InvetorySpace):
			self.Contents.append(None)

	def AddToInventory(self, Item):
		(NotFull, Index) = self.CheckIsNotInventoryFull()

		if NotFull:
			self.Contents[Index] = Item
		else:
			print("Inventory is full")

	def AccessInventory(self, Player, Room):
		while True:
			self.PrintInventoryContents()
			Selected = None

			print("1) Use")
			print("2) Destroy")
			print("3) Item Description")
			print("4) Exit")
			Useage = input("Enter Useage >> ")

			if Useage == "4":
				return

			while True:
				Selected = int(input("Enter Item >> "))
				
				if Selected < 0 or Selected > len(self.Contents) or self.Contents[Selected] == None:
					print("Please enter a valid number")
					continue
				else:
					break

			if Useage == "1":
				self.Contents[Selected].OnUse(Player, Room)
				self.Contents[Selected] = None
				break
			elif Useage == "2":
				self.Contents[Selected] = None
				break
			elif Useage == "3":
				print(self.Contents[Selected].ItemDescription)
				break

	def CheckIsNotInventoryFull(self):
		for i in range(0, len(self.Contents)):
			if self.Contents[i] == None:
				return (True, i)

	def PrintInventoryContents(self):
		for i in range(0, len(self.Contents)):
			if self.Contents[i] != None:		
				print(i, "-", self.Contents[i].ItemName)
			else:
				print(i, "- Empty slot")