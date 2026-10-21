#pragma once

#include "GuiControl.h"
#include "AssetLoader.h"

#include <SFML\System.hpp>
#include <SFML\Window.hpp>
#include <SFML\Graphics.hpp>

#include <string>

class GuiImage : public GuiControl
{
private:
	std::string		_ImagePath;
	sf::Sprite		_Image;

public:
	GuiImage(std::string image);
	~GuiImage(void);

	void Init(AssetLoader* loader);
	void Draw(sf::RenderWindow* window);
	void Update(sf::RenderWindow* window);
	void Inline();
};

