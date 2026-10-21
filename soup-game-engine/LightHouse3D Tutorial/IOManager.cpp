#include "IOManager.h"


IOManager::IOManager(void)
{
}


IOManager::~IOManager(void)
{
}

void IOManager::processKeyPress(unsigned char key, int x, int y)
{
	if(key == 27)
		exit(0);
}

void IOManager::processSpecialKeyPress(int key, int x, int y)
{
	extern float red, green, blue, a, b;

	switch(key)
	{
	case GLUT_KEY_F1:
		red = 1.0;
		green = 0.0;
		blue = 0.0;
	break;
	case GLUT_KEY_F2:
		red = 0.0;
		green = 1.0;
		blue = 0.0; 
	break;
	case GLUT_KEY_F3:
		red = 0.0;
		green = 0.0;
		blue = 1.0; 
	break;
	case GLUT_KEY_DOWN:
		a += 1;
	break;
	case GLUT_KEY_UP:
		a -= 1;
	break;
	case GLUT_KEY_LEFT:
		b += 1;
	break;
	case GLUT_KEY_RIGHT:
		b -= 1;
	break;
	}
}
