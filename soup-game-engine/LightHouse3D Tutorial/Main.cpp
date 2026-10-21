#include <stdlib.h>
#include <Windows.h>

#include "IOManager.h"
#include "MainGame.h"
///Tarn the engine

float angle = 0.0;

float red = 1, green, blue;
float a = 2.0f;
float b = 0.0f;

int main(int argc, char** argv)
{
	MainGame Game = MainGame(&argc, argv);
	Game.createWindow(800, 600, "Tarn");

	///Register Callbacks
	glutDisplayFunc(&MainGame::renderScene);

	///New entry in the main function
	glutReshapeFunc(&MainGame::changeSize);

	///Idle
	glutIdleFunc(&MainGame::renderScene);

	///Handles the key input
	glutKeyboardFunc(&IOManager::processKeyPress);

	///Handles special key presses (e.g. F1 ->)
	glutSpecialFunc(&IOManager::processSpecialKeyPress);

	///Enter GLUT event processing cycle
	glutMainLoop();

	return 0;
}