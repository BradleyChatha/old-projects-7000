class String:
	@staticmethod
	def IsNumerical(String : str) -> bool:
		try:
			int(String)
			return True
		except:
			return False