#include "GuiButton.h"

using namespace sf;
using namespace std;

GuiButton::GuiButton(string buttonTexture, string fontPath) : _TexturePath(buttonTexture), _ClickLock(false), _FontPath(fontPath)
{
}


GuiButton::~GuiButton(void)
{
}

GuiButton::GuiButton(string buttonTexture, function<void(GuiButton*)> evnt, string fontPath) : _TexturePath(buttonTexture), _ClickLock(false), _Event(evnt), _FontPath(fontPath)
{
}

void GuiButton::Init(AssetLoader* loader)
{
	this->_Sprite.setTexture(loader->LoadTexture(this->_TexturePath), true);

	// If we have a font to load in... Then... load it in...?
	if(this->_FontPath != "")
	{
		this->_Text.setFont(loader->LoadFont(this->_FontPath));
	}
}

void GuiButton::Draw(RenderWindow* window)
{
	window->draw(this->_Sprite);
	window->draw(this->_Text);
}

void GuiButton::Update(RenderWindow* window)
{
	if(this->IsMouseOverSprite(this->_Sprite, window))
	{
		if(Mouse::isButtonPressed(Mouse::Left))
		{
			this->_Sprite.setColor(Color(64, 64, 64, 255));
			// Invoke the event, if one exists
			if(this->_Event != nullptr && !this->_ClickLock)
			{
				this->_Event(this);
				this->_ClickLock = true;
			}
		}
		else
		{
			this->_Sprite.setColor(Color(128, 128, 128, 255));
			this->_ClickLock = false;
		}
	}
	else
	{
		this->_Sprite.setColor(Color(255, 255, 255, 255));
	}

	// Keep the text centered within the button(I R C++ PRUGRUMMUR).... I used stupid names for my variables
	Vector2u TSize = this->_Sprite.getTexture()->getSize();
	Vector2f Pos = this->GetPosition();
	FloatRect TxtSize = this->_Text.getLocalBounds();

	this->_Text.setPosition(
		((Pos.x + (TSize.x / 2)) - (TxtSize.width / 2)),
		((Pos.y + (TSize.y / 2)) - (TxtSize.height / 2))
		);
}

void GuiButton::SetClickEvent(function<void(GuiButton*)> evnt)
{
	this->_Event = evnt;
}

void GuiButton::Inline()
{
	this->_Sprite.setPosition(this->GetPosition());
}

void GuiButton::SetButtonText(String s, Uint32 size, Color color)
{
	this->_Text.setString(s);
	this->_Text.setCharacterSize(size);
	this->_Text.setColor(color);
}