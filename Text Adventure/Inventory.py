from Item import *

class Inventory:
	def __init__(self):
		self.Contents = []
		self.InvetorySpace = 10

		for i in range(0, self.InvetorySpace):
			self.Contents.append(None)

	def Update(self, Command, Item = None):
		if Command == "Add":
			if self.CheckIsNotInventoryFull():
				if Item:
					pass #Add item here
				else:
					print("Please enter an item to add")
					return
			else:
				print("Inventory full")
				return
		elif Command == "View":
			while True:
				self.PrintInventoryContents()
				Selected = None
				while True:
					Selected = int(input("Enter Item >> "))

					if Selected > 0 or Selected < len(self.Contents):
						print("Please enter a valid number")
						continue
					else:
						break

				print("1) Use")
				print("2) Destroy")
				print("3) Exit")
				Useage = input("Enter Useage >> ")

				if Useage == "1":
					pass
				elif Useage == "2":
					pass
				elif Useage == "3":
					return

	def CheckIsNotInventoryFull(self):
		for i in range(0, len(self.Contents)):
			if i == None:
				return (True, i)


	def PrintInventoryContents(self):
		for i in range(0, len(self.Contents)):
			print(i, "-", self.Contents[i])