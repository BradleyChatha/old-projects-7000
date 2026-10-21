#include "MainGame.h"


MainGame::MainGame(void){}

MainGame::MainGame(int* argc, char** argv)
{
	///Initalizes GLUT/FREEGLUT
	glutInit(argc, argv);
}

MainGame::~MainGame(void){}

void MainGame::createWindow(int x, int y, string title = "")
{
	///Sets the mode to display in
	glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH);
	///The position of the window. -1, -1 by default
	glutInitWindowPosition(1, 1);
	///Sets the size of the window.
	glutInitWindowSize(x, y);
	///Sets the window title
	glutCreateWindow(title.c_str());
}

void MainGame::renderScene(void)
{

	extern float red;
	extern float green;
	extern float blue;
	extern float a, b;
	float angle = 0.0f;

	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	///Reset transformations
	glLoadIdentity();

	///Look at the camera
	gluLookAt(0.0f, 0.0f, 10.0f,
			  0.0f, 0.0f, 0.0f,
			  0.0f, 1.0f, 0.0f);

	///Rotate the triangle
	glRotatef(angle, 0.0f, 1.0f, 0.0f);

	///Set the colour of the triangle
	glColor3f(red, green, blue);
	glBegin(GL_TRIANGLES);
		glVertex3f(-2.0f,-a, 0.0f);
		glVertex3f( a, a+b, b);
		glVertex3f( b, 2.0f, a);
	glEnd();

	angle += 0.1f;

	glutSwapBuffers();
}

void MainGame::changeSize(int w, int h)
{
	///To prevent divide by 0.
	if(h == 0)
		h = 1;

	float ratio = 1.0 * w / h;

	///Use the projection matrix
	glMatrixMode(GL_PROJECTION);

	///Reset matix
	glLoadIdentity();

	///Set the view port
	glViewport(0, 0, w, h);

	///Set the correct prospective
	gluPerspective(45, ratio, 1, 1000);

	///Get back to the model view
	glMatrixMode(GL_MODELVIEW);
}