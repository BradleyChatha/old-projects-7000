#pragma once

#include "GuiControl.h"
#include "AssetLoader.h"

#include <SFML\System.hpp>
#include <SFML\Window.hpp>
#include <SFML\Graphics.hpp>

#include <string>
#include <functional>

class GuiButton : public GuiControl
{
private:
	sf::Sprite						_Sprite;
	sf::Text						_Text;

	std::string						_TexturePath;
	std::string						_FontPath;

	std::function<void(GuiButton*)> _Event;

	bool							_ClickLock;

public:
	/// Create a new GuiButton that uses "buttonTexture" as it's texture, and "font" as the text font(For no font, just use "")
	GuiButton(std::string buttonTexture, std::string font = "");

	/// Create a new GuiButton that uses "buttonTexture" as it's texture, "font" as the text font, and uses "evnt" as it's OnClickEvent
	GuiButton(std::string buttonTexture, std::function<void(GuiButton*)> evnt, std::string font = "");
	~GuiButton(void);

	void Init(AssetLoader* loader);
	void Draw(sf::RenderWindow* window);
	void Update(sf::RenderWindow* window);
	void Inline();

	/// Set the OnClickEvent for button
	void SetClickEvent(std::function<void(GuiButton*)> evnt);

	/// Set what text the button should show. data can be any type of string(Incase you want to have a German version of the game ;) )
	void SetButtonText(sf::String data, sf::Uint32 characterSize, sf::Color color);
};

