#include "Core.h"

Core::Core()
{
	this->GameWindow = nullptr;
}

Core::~Core()
{
	delete this->GameWindow;
}

void Core::CreateWindow(string Title, unsigned int Width, unsigned int Height)
{
	this->GameWindow = new RenderWindow(VideoMode(Width, Height, 32), Title);

	Logger::Write("[Core] Created a GameWindow.");
}

RenderWindow* Core::GetWindowInstance(void)
{
	if (!this->GameWindow)
		throw runtime_error("[Core] GameWindow is nullptr.");

	return this->GameWindow;
}

void Core::SetFrameRate(int FrameRate)
{
	if (!this->GameWindow)
		throw runtime_error("[Core] GameWindow is nullptr.");

	this->GameWindow->setFramerateLimit(FrameRate);
	
	if (FrameRate == 0)
		Logger::Write("[Core] FPS limit has been removed");
	else
		Logger::Write("[Core] FPS limit set to " + to_string(FrameRate) + " FPS.");
}

void Core::SetVSync(bool VSync)
{
	if (!this->GameWindow)
		throw runtime_error("[Core] GameWindow is nullptr.");

	this->GameWindow->setVerticalSyncEnabled(VSync);

	if(VSync)
		Logger::Write("[Core] VSync has been enabled.");
	else
		Logger::Write("[Core] VSync has been disabled.");
}

void Core::AddUpdateFunction(function<void(Time)> Function)
{
	this->UpdateFunctions.push_back(Function);
}

void Core::AddDrawFunction(function<void(RenderWindow&)> Function)
{
	this->DrawFunctions.push_back(Function);
}

void Core::AddEventFunction(Event::EventType KeyEvent, function<void(void)> Function)
{
	this->OnEventFunctions[KeyEvent] = Function;
}

void Core::Run(void)
{
	if (!this->GameWindow)
		throw runtime_error("[Core] GameWindow is nullptr.");

	while (this->GameWindow->isOpen())
	{
		this->FrameCounter.restart();
		while (this->GameWindow->pollEvent(this->GameEvent))
		{
			if(this->OnEventFunctions.find(this->GameEvent.type) != this->OnEventFunctions.end())
				this->OnEventFunctions[this->GameEvent.type]();
		}

		///The update functions
		for (int i = 0; i < this->UpdateFunctions.size(); i++)
		{
			this->UpdateFunctions[i](this->DeltaTime);
		}

		this->GameWindow->clear();
		///The draw functions
		for (int i = 0; i < this->DrawFunctions.size(); i++)
		{
			this->DrawFunctions[i](*this->GameWindow);
		}
		this->GameWindow->display();
		this->DeltaTime = this->FrameCounter.getElapsedTime();
	}
}
