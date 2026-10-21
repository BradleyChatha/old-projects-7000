#pragma once

#include "GuiControl.h"
#include "AssetLoader.h"

#include <SFML\System.hpp>
#include <SFML\Window.hpp>
#include <SFML\Graphics.hpp>

#include <string>
#include <map>

class GuiTextbox : public GuiControl
{
private:
	sf::Sprite						_Sprite;
	sf::Text						_Text;

	std::string						_FontPath;
	std::string						_TexturePath;
	bool							_IsPassword;
	bool							_IsSelected;

	std::map<unsigned char, bool>	_LockMap;

public:
	GuiTextbox(std::string font, std::string texture, bool isPasswordBox);
	~GuiTextbox(void);

	void Init(AssetLoader* loader);
	void Draw(sf::RenderWindow* window);
	void Update(sf::RenderWindow* window);
	void Inline();

	sf::String GetText();
	void SetTextSettings(sf::Uint32 characterSize, sf::Color color);
};

