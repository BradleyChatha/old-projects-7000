import xml.etree.cElementTree as ET
from random import *
from Entity import *

class Room:
	def __init__(self, RoomFile : str, Player):
		self.Path = "Data\\" + RoomFile
		self.RoomXML = ET.parse(self.Path).getroot()
		self.Default = "Dead end"
		self.AttachedRooms = {"North" : self.Default, "East" : self.Default, "South" : self.Default, "West" : self.Default}
		self.Description = ""

		self.Enemy = choice([Slime(Player), None])

		self.ProcessRoom()

	def __str__(self) -> str:
		if self.Enemy != None:
			Message = self.Enemy.Description
		else:
			Message = "There are no enemies in this room"
		return Message + "\n" + self.Description

	#Processes the current room, and finds the description of the next exit/entrance to another room.
	def ProcessRoom(self):
		for Element in self.RoomXML.findall("Direction"):
			Direction = Element.get("Compass")

			if Direction == "North":
				self.AttachedRooms["North"] = Element.text
			elif Direction == "East":
				self.AttachedRooms["East"] = Element.text
			elif Direction == "South":
				self.AttachedRooms["South"] = Element.text
			elif Direction == "West":
				self.AttachedRooms["West"] = Element.text

		self.Description = self.RoomXML.find("Description").text
		print(self)
 
	def Update(self, Player):
		if self.Enemy != None:
			self.Enemy = self.Enemy.Update(Player)

 	#Attempts to load another room.
 	#Returns the next room that the player is in, if the requested direction contains an exit/entrance.
 	#Otherwise this instance of room is returned and the description of that direction is returned.
	def LoadNextRoom(self, Direction : str, Player):
		if Direction in self.AttachedRooms:
			if self.AttachedRooms[Direction].endswith(".xml"):
				return Room(self.AttachedRooms[Direction], Player)
			else:
				print(self.AttachedRooms[Direction])
				return self