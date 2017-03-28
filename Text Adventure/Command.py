"""			Cmd = Command.Input()

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
"""

class Command:
	def __init__(self, CommandName, Description, Action):
		self.Command = CommandName
		self.Description = Description
		self.Action = Action

def MoveNorth(Player, Room):
	Room.LoadNextRoom("North", Player)

def MoveSouth(Player, Room):
	Room.LoadNextRoom("South", Player)

def MoveEast(Player, Room):
	Room.LoadNextRoom("East", Player)

def MoveWest(Player, Room):
	Room.LoadNextRoom("West", Player)

def Attack(Player, Room):
	if Room.Enemy != None:
		Room.Enemy.TakeDamage(Player.Attack())
		Room.Enemy.Attack(Player)
	else:
		print("There is nothing to attack")

def Self(Player, Room):
	print(Player)

def PickUpItem(Player, Room):
	if Room.DroppedItem != None:
		print("You picked up ", Room.DroppedItem.ItemName)
		Player.Bag.AddToInventory(Room.DroppedItem)
		Room.DroppedItem = None
	else:
		print("Nothing to pick up")

def AccessInventory(Player, Room):
	Player.Bag.AccessInventory(Player, Room)

class CommandHandler:
	def __init__(self):
		self.Commands = \
		{
			"north" : Command("North", "Move north", MoveNorth),
			"south" : Command("South", "Move south", MoveSouth),
			"east" : Command("East", "Move east", MoveEast),
			"west" : Command("West", "Move west", MoveWest),

			"attack" : Command("Attack", "Attack the enemy in the room", Attack),
			"self" : Command("Self", "Prints the player information", Self),

			"pickup" : Command("Pickup", "Picks up an item", PickUpItem),
			"bag" : Command("Bag", "Looks in your inventory", AccessInventory)
		}

	def Update(self, Player, Room):
		Cmd = input(">> ").lower()

		if Cmd in self.Commands:
			self.Commands[Cmd].Action(Player, Room)
		elif Cmd == "help":
			for Element in self.Commands:
				print(self.Commands[Element].Command, "-", self.Commands[Element].Description)
		else:
			print("Invalid command")