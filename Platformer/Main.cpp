#include <SFML\Graphics.hpp>
#include <SFML\Main.hpp>
#include <fstream>

#include "Player.h"
#include "Core.h"
#include "Logger.h"

using namespace sf;

int main(int argc, char** argv)
{
	try
	{
		Logger::Init();
		fstream SaveFile("Assets\\Saves\\Test.dat", ios::out | ios::binary);

		Core Engine = Core();
		Player player = Player();
		Engine.AddEventFunction(Event::Closed, [&Engine]() { Engine.GetWindowInstance()->close(); });
		Engine.AddDrawFunction([&player](RenderWindow& GameWindow) { player.draw(GameWindow); });
		Engine.AddUpdateFunction([&player](Time DeltaTime) { player.Update(DeltaTime); });

		Engine.CreateWindow("Platformer", 800, 600);
		Engine.SetFrameRate(60);
		Engine.Run();
	}
	catch (exception &e)
	{
		Logger::Write(string(e.what()), LogType::Fatal);
	}

	Logger::Stop();

	system("PAUSE");
	return 0;
}