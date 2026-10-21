#pragma once

#include <GL\glut.h>
#include <string>

using namespace std;

class MainGame
{
public:
	MainGame(void);
	MainGame(int* argc, char** argv);
	~MainGame(void);

	void createWindow(int x, int y, string title);
	static void renderScene(void);
	static void changeSize(int w, int h);
};

