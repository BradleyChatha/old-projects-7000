from Character import *
from GameManager import *
from Room import *

PlayerName = input("Enter a name for your player: ")
TextGame = Game(Character(PlayerName))

TextGame.Run()