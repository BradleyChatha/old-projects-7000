#pragma once

#include <GL/glut.h>

class IOManager
{
public:
	IOManager(void);
	~IOManager(void);

	static void processSpecialKeyPress(int key, int x, int y);
	static void processKeyPress(unsigned char key, int x, int y);
};

