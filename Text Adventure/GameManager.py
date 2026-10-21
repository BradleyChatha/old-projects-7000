from Command import *
from Room import * 

class Game:
	def __init__(self, Player):
		self.PlayerRef = Player
		self.IsGameRunning = True
		self.Room = Room("StartRoom.xml", Player)
		self.Directions = ["North", "East", "South", "West"]
		self.Handler = CommandHandler()

	#Contains the main logic for the game
	def Run(self):
		while self.IsGameRunning:
			self.Handler.Update(self.PlayerRef, self.Room)

			self.Room.Update(self.PlayerRef)

	#Checkis the command which is passed to it (Cmd) is a direction.
	#See self.Direction for those values.
	#Returns true if Cmd is a direction
	#Returns false otherwise.
	def DirectionsContains(self, Cmd) -> bool:
		for Element in self.Directions:
			if Element == Cmd:
				return True
		return False