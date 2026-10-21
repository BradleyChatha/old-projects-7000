#ifndef HANDLE_H
#define HANDLE_H

#include "screen.h"
#include "kb.h"
#include "types.h"

void main()
{
	clearScreen();
		
	print("Welcome to SOS!\n");
	
	printLength("Tarn", strLength("Tarn"));
	
	while(1)
	{
		print("\nSOS >> ");
		string input = readStr();
			
		if(strEql(input, "clear"))
		{
			clearScreen();
		}
		else
		{
			print("\nUnkown command!");
		}
	}
}

#endif