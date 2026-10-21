#ifndef SCREEN_H
#define SCREEN_H

#include "types.h"
#include "system.h"
#include "string.h"
#include "Colour.h"

int cursorX = 0, cursorY = 0;
const uint8 screenWidth = 80, screenHeight = 25, screenDepth = 2; ///Define the screens width, height and depth

void clearLine(uint8 from, uint8 to)
{
	uint16 i = screenWidth * from * screenDepth;
	string videoMemory = (string)0xb8000;
	
	for(; i < (screenWidth * (to + 1) * screenDepth); i++)
	{
		videoMemory[i] = 0x0; ///Pad the line with black... I think thats the colour one
	}
}

void updateCursor(void)
{
	uint8 temp;
	
	temp = cursorY * screenWidth + cursorX; ///Position = (y*width)+x
	
	outportb(0x3D4, 14);			///CRT control register: select the cursor location
	outportb(0x3D5, temp >> 8);		///Send the high byte across the bus
	outportb(0x3D4, 15);			///CRT control register: select send low byte
	outportb(0x3D5, temp);			///Send the low byte across the bus
}

void clearScreen(void)
{
	clearLine(0, screenHeight-1);
	cursorX = 0;
	cursorY = 0;
	updateCursor();
}

void scrollUp(uint8 lineNumber)
{
	string videoMemory = (string)0xb8000;
	uint16 i = 0;
	
	for(;i < screenWidth * (screenHeight - 1) * screenDepth; i++)
	{
		videoMemory[i] = videoMemory[i + screenWidth * 2 * lineNumber];
	}
	clearLine(screenHeight - 1 - lineNumber, screenHeight - 1);
	
	if((cursorY - lineNumber) < 0)
	{
		cursorY = 0;
		cursorX = 0;	
	}
	else
	{
		cursorY -= lineNumber;
	}
	
	updateCursor();
}

void newLineCheck(void)
{
	if(cursorY >= screenHeight - 1)
	{
		scrollUp(1);
	}
}

void printCh(char c)
{
	string videoMemory = (string)0xb8000;
	
	switch(c)
	{
		case (0x08):
			if(cursorX > 0)
			{
				cursorX--;
				videoMemory[(cursorY * screenWidth + cursorX) * screenDepth] = 0x00;	
			}
		break;
		case (0x09):
			cursorX = (cursorX + 8) & ~(8 -1);
		break;
		case ('\r'):
			cursorX = 0;
		break;
		case ('\n'):
			cursorX = 0;
			cursorY++;
		break;
		default:
			videoMemory[(cursorY * screenWidth + cursorX) * screenDepth] = c;
			videoMemory[(cursorY * screenWidth + cursorX) * screenDepth + 1] = 0x0F;
			cursorX++;
		break;
	}
	if(cursorX >= screenWidth)
	{
		cursorX = 0;
		cursorY++;
	}
	
	newLineCheck();
	updateCursor();
}

void printLength(string s, uint32 length)
{
	uint16 i = 0;
	
	for(; i < length; i++)
	{		
		printCh(s[i]);
	}
}

void print(string s)
{
	printLength(s, strLength(s));
}

#endif
