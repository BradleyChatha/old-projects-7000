from Command import *
from Room import * 

class Game:
	def __init__(self, Player):
		self.PlayerRef = Player
		self.IsGameRunning = True
		self.Room = Room("StartRoom.xml", Player)
		self.Directions = ["North", "East", "South", "West"]

	#Contains the main logic for the game
	def Run(self):
		while self.IsGameRunning:
			self.Room.Update(self.PlayerRef)

			Cmd = Command.Input()

			if self.DirectionsContains(Cmd["Command"][0]):
				self.Room = self.Room.LoadNextRoom(Cmd["Command"][0], self.PlayerRef)

			elif Cmd["Command"][0] == "Attack":
				if self.Room.Enemy != None and self.Room.Enemy.CurrentHealth > 0:
					self.Room.Enemy.TakeDamage(self.PlayerRef.Attack())
					self.Room.Enemy.Attack(self.PlayerRef)
				elif self.Room.Enemy == None or self.Room.Enemy.CurrentHealth <= 0:
					print("There is nothing to attack, the room is empty.")

			elif Cmd["Command"][0] == "Player" or Cmd["Command"][0] == "Self":
				print(self.PlayerRef)

	#Checkis the command which is passed to it (Cmd) is a direction.
	#See self.Direction for those values.
	#Returns true if Cmd is a direction
	#Returns false otherwise.
	def DirectionsContains(self, Cmd) -> bool:
		for Element in self.Directions:
			if Element == Cmd:
				return True
		return False