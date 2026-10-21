#pragma once

#include <SFML\Graphics.hpp>
#include <functional>
#include <string>
#include <vector>
#include <map>
#include <iostream>
#include "Logger.h"

using namespace sf;
using namespace std;

class Core
{
public:
	Core();
	~Core();

	/*
	*	Creates a new window.
	*	Params:
	*		string Title - The title to be displayed at the top of the window.
	*		unsigned int Width - How wide the window is.
	*		unsigned int Height - How tall the window is.
	*/
	void CreateWindow(string Title, unsigned int Width, unsigned int Height);

	/*
	*	Gets the RenderWindow currently used.
	*	Returns the RenderWindow.
	*	Exceptions:
	*		Runtime_error - thrown if GameWindow* is a nullptr.
	*/
	RenderWindow* GetWindowInstance(void);

	/*
	*	Sets the framerate limit for the window. If the limit is set to 0 then the limit is removed
	*	and the framerate becomes as high as the hardware will allow.
	*	Params:
	*		int FrameRate - The framerate of the window.
	*	Exceptions:
	*		Runtime_error - thrown if GameWindow* is a nullptr.
	*/
	void SetFrameRate(int FrameRate);

	/*
	*	Enables or disables v-sync on the window.
	*	Params:
	*		bool VSync - The setting for v-sync.
	*	Exceptions:
	*		Runtime_error - thrown if GameWindow* is a nullptr.
	*/
	void SetVSync(bool VSync);

	/*
	*	Adds functions to the UpdateFunctions vector.
	*	Params:
	*		function<void(float)> Function - The function to add to the vector.
	*/
	void AddUpdateFunction(function<void(Time)> Function);

	/*
	*	Adds functions to the DrawFunctions vector.
	*	Params:
	*		function<void(float)> Function - The function to add to the vector.
	*/
	void AddDrawFunction(function<void(RenderWindow&)> Function);

	/*
	*	Adds functions to the OnEventFunctions the key to call them is when a registered sf::Event happens.
	*	Params:
	*		Event::EventType KeyEvent - The event to trigger the funciton.
	*		function<void(void)> Function - The function to add to the map.
	*/
	void AddEventFunction(Event::EventType KeyEvent, function<void(void)> Function);

	/*
	*	Runs the main game loop and all of the game logic.
	*	Exceptions:
	*		Runtime_error - thrown if GameWindow* is a nullptr.
	*/
	void Run(void);

private:
	RenderWindow* GameWindow;
	Event GameEvent;
	Clock FrameCounter;
	Time DeltaTime;
	vector<function<void(Time)>> UpdateFunctions;
	vector<function<void(RenderWindow&)>> DrawFunctions;
	map<Event::EventType, function<void(void)>> OnEventFunctions;
};

