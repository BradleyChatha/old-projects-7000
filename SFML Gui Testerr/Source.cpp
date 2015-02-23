#include "GuiButton.h"
#include "GuiImage.h"
#include "GuiTextbox.h"
#include "AssetLoader.h"
#include "GuiControl.h"

#include <SFML\Graphics.hpp>
#include <SFML\System.hpp>

#include <iostream>
#include <string>

using namespace std;
using namespace sf;

void Handle(GuiButton* sender)
{
	cout << "The button worked!" << endl;
}

int main(void)
{
	RenderWindow *window = new RenderWindow(VideoMode(800, 600, 32), "Window", Style::Close);
	Event e;

	window->setFramerateLimit(60);

	// Create a new AssetLoader. The AssetLoader is used as a resource cache, to save time and memory.
	AssetLoader Loader;

	// Create the main GuiContainer.
	// The GuiContainer as it's name implies, contains Gui controls.
	// It's use is to neatly handle large groups of controls, so I recommend using one of these instead of using individual controls
	// Furthermore, any control in a Container will have it's position relative to the container's position.
	// So if the container's position was (10, 0), and a control's(A control that is already in the container) position is (5, 10), then the control's final position would end up being(15, 10)
	// If you're thinking "How can a Container be useful", think of having an inventory window that you can freely move around the screen. The GuiContainer will handle moving and keeping the controls lined up for you.
	GuiContainer Container;
	Container.Init(&Loader); // Initialise the container, giving it the AssetLoader so it can load in Gui controls later.
	Container.SetPosition(Vector2f(0, 0)); // Set it's position to (0, 0).

	// Here's where you might get a bit confused
	// First we make a new GuiButton
	// The second constructor(The one I use below) looks like this
	//
	// GuiButton(std::string buttonTexture, std::function<void(GuiButton*)> evnt, std::string font = "");
	// Param 1 = The texture for the button to use
	// Param 2 = The function to call when the button is clicked on(The function must only take a single parameter, a GuiButton*)
	// Param 3 = The font to use for the button's text(Use "" if you're not planning on giving it text)
	//
	// The second parameter for AddControl is the ID to give the control. The ID can be used to later access the control
	/*
	So to wrap up this line:

	"Add a Button to Container, this Button uses the texture at 'Assets/TestButton.png' and will call the function 'Handle' when clicked. The ID of the button shall be 'Button01'"
	*/
	Container.AddControl(new GuiButton("Assets/TestButton.png", &Handle, "Assets/arial.ttf"), "Button01");

	// Here we ask our Container to return the control with the ID "Button01"... The button we just added to it
	// Then we set the position of that button to (100, 50)
	// And then we do stuff to setup it's text
	Container.GetControl<GuiButton>("Button01")->SetPosition(Vector2f(100, 50));

	// Putting "L" before a string turns it into a std::wstring, where each character is 16-bits, instead of 8.
	Container.GetControl<GuiButton>("Button01")->SetButtonText("Soupworld's chode of sexy", 18, Color::Black);

	// Pretty much the same thing as before, the first parameter for GuiImage is the image file to use.
	Container.AddControl(new GuiImage("Assets/Image.png"), "Image01");
	Container.GetControl<GuiImage>("Image01")->SetPosition(Vector2f(100, 200));

	Container.AddControl(new GuiTextbox("Assets/arial.ttf", "Assets/TestButton.png", false), "Textbox01");
	Container.GetControl<GuiTextbox>("Textbox01")->SetPosition(Vector2f(350, 50));
	Container.GetControl<GuiTextbox>("Textbox01")->SetTextSettings(18, Color::Black);

	while(window->isOpen())
	{
		window->clear(Color::White);

		while(window->pollEvent(e))
		{
			if(e.type == Event::Closed)
			{
				window->close();
			}
		}

		// These functions Draw and update every control in the container
		Container.Draw(window);
		Container.Update(window);

		// Just to show you how the container's position system works, using the arrow keys you can change the Container's position, you should see every control move on the screen because of this
		if(Keyboard::isKeyPressed(Keyboard::Key::Left))
		{
			Container.Move(Vector2f(-1, 0));
		}
		if(Keyboard::isKeyPressed(Keyboard::Key::Right))
		{
			Container.Move(Vector2f(1, 0));
		}
		if(Keyboard::isKeyPressed(Keyboard::Key::Down))
		{
			Container.Move(Vector2f(0, 1));
		}
		if(Keyboard::isKeyPressed(Keyboard::Key::Up))
		{
			Container.Move(Vector2f(0, -1));
		}

		window->display();
	}

	delete window;
	return 0;
}