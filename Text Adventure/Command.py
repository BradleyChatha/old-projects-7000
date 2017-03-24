class Command:
	@staticmethod
	def Input():
		String = input(">> ")
		String = String.split(' ')
		return {"Length" : len(String), "Command" : String}