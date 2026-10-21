#include "GuiTextbox.h"

#include <vector>

using namespace std;
using namespace sf;

vector<char> GetPressedKeys();

GuiTextbox::GuiTextbox(string font, string texture, bool isp) : _IsPassword(isp), _FontPath(font), _TexturePath(texture), _IsSelected(false)
{
}


GuiTextbox::~GuiTextbox(void)
{
}


void GuiTextbox::Init(AssetLoader* loader)
{
	this->_Sprite.setTexture(loader->LoadTexture(this->_TexturePath), true);
	this->_Text.setFont(loader->LoadFont(this->_FontPath));

	// Stops a subscript out of range exception
	for(unsigned short c = 0; c < 256; c++)
	{
		this->_LockMap[(unsigned char)c] = false;
	}
}

void GuiTextbox::Draw(RenderWindow* window)
{
	window->draw(this->_Sprite);
	window->draw(this->_Text);
}

void GuiTextbox::Update(RenderWindow* window)
{
	if(Mouse::isButtonPressed(Mouse::Button::Left))
	{
		if(this->IsMouseOverSprite(this->_Sprite, window))
		{
			this->_IsSelected = true;
		}
		else
		{
			this->_IsSelected = false;
		}
	}

	if(!this->_IsSelected)
	{
		this->_Sprite.setColor(Color(200, 200, 200, 255));
		return;
	}
	else
	{
		this->_Sprite.setColor(Color(255, 255, 255, 255));
	}

	vector<char> Pressed = GetPressedKeys();

	if(Pressed.size() != 0)
	{
		string Bebs = this->_Text.getString();

		for(unsigned int i = 0; i < Pressed.size(); i++)
		{
			// Prevents keys registering multiple times
			if(this->_LockMap[Pressed[i]])
			{
				continue;
			}

			if(Pressed[i] != '\b')
			{
				Bebs += Pressed[i];
			}
			else
			{
				if(Bebs.size() > 0)
					Bebs.resize(Bebs.size() - 1);
			}
		}

		this->_Text.setString(Bebs);
	}

	for(unsigned short i = 0; i < 256; i++)
	{
		for(unsigned int i2 = 0; i2 < Pressed.size(); i2++)
		{
			if((unsigned char)i == Pressed[i2])
			{
				this->_LockMap[(unsigned char)i] = true;
			}
			else
			{
				this->_LockMap[(unsigned char)i] = false;
			}
		}

		if(Pressed.size() == 0)
		{
			this->_LockMap[(unsigned char)i] = false;
		}
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

void GuiTextbox::Inline()
{
	this->_Sprite.setPosition(this->GetPosition());
}

String GuiTextbox::GetText()
{
	return this->_Text.getString();
}

void GuiTextbox::SetTextSettings(Uint32 size, Color colour)
{
	this->_Text.setCharacterSize(size);
	this->_Text.setColor(colour);
}

vector<char> GetPressedKeys()
{
	vector<char> ToReturn;

	if(Keyboard::isKeyPressed(Keyboard::Key::LShift) || Keyboard::isKeyPressed(Keyboard::Key::RShift))
	{
		if(Keyboard::isKeyPressed(Keyboard::Key::A)) ToReturn.push_back('A');
		if(Keyboard::isKeyPressed(Keyboard::Key::B)) ToReturn.push_back('B');
		if(Keyboard::isKeyPressed(Keyboard::Key::C)) ToReturn.push_back('C');
		if(Keyboard::isKeyPressed(Keyboard::Key::D)) ToReturn.push_back('D');
		if(Keyboard::isKeyPressed(Keyboard::Key::E)) ToReturn.push_back('E');
		if(Keyboard::isKeyPressed(Keyboard::Key::F)) ToReturn.push_back('F');
		if(Keyboard::isKeyPressed(Keyboard::Key::G)) ToReturn.push_back('G');
		if(Keyboard::isKeyPressed(Keyboard::Key::H)) ToReturn.push_back('H');
		if(Keyboard::isKeyPressed(Keyboard::Key::I)) ToReturn.push_back('I');
		if(Keyboard::isKeyPressed(Keyboard::Key::J)) ToReturn.push_back('J');
		if(Keyboard::isKeyPressed(Keyboard::Key::K)) ToReturn.push_back('K');
		if(Keyboard::isKeyPressed(Keyboard::Key::L)) ToReturn.push_back('L');
		if(Keyboard::isKeyPressed(Keyboard::Key::M)) ToReturn.push_back('M');
		if(Keyboard::isKeyPressed(Keyboard::Key::N)) ToReturn.push_back('N');
		if(Keyboard::isKeyPressed(Keyboard::Key::O)) ToReturn.push_back('O');
		if(Keyboard::isKeyPressed(Keyboard::Key::P)) ToReturn.push_back('P');
		if(Keyboard::isKeyPressed(Keyboard::Key::Q)) ToReturn.push_back('Q');
		if(Keyboard::isKeyPressed(Keyboard::Key::R)) ToReturn.push_back('R');
		if(Keyboard::isKeyPressed(Keyboard::Key::S)) ToReturn.push_back('S');
		if(Keyboard::isKeyPressed(Keyboard::Key::T)) ToReturn.push_back('T');
		if(Keyboard::isKeyPressed(Keyboard::Key::U)) ToReturn.push_back('U');
		if(Keyboard::isKeyPressed(Keyboard::Key::V)) ToReturn.push_back('V');
		if(Keyboard::isKeyPressed(Keyboard::Key::W)) ToReturn.push_back('W');
		if(Keyboard::isKeyPressed(Keyboard::Key::X)) ToReturn.push_back('X');
		if(Keyboard::isKeyPressed(Keyboard::Key::Y)) ToReturn.push_back('Y');
		if(Keyboard::isKeyPressed(Keyboard::Key::Z)) ToReturn.push_back('Z');
	}
	else
	{
		if(Keyboard::isKeyPressed(Keyboard::Key::A)) ToReturn.push_back('a');
		if(Keyboard::isKeyPressed(Keyboard::Key::B)) ToReturn.push_back('b');
		if(Keyboard::isKeyPressed(Keyboard::Key::C)) ToReturn.push_back('c');
		if(Keyboard::isKeyPressed(Keyboard::Key::D)) ToReturn.push_back('d');
		if(Keyboard::isKeyPressed(Keyboard::Key::E)) ToReturn.push_back('e');
		if(Keyboard::isKeyPressed(Keyboard::Key::F)) ToReturn.push_back('f');
		if(Keyboard::isKeyPressed(Keyboard::Key::G)) ToReturn.push_back('g');
		if(Keyboard::isKeyPressed(Keyboard::Key::H)) ToReturn.push_back('h');
		if(Keyboard::isKeyPressed(Keyboard::Key::I)) ToReturn.push_back('i');
		if(Keyboard::isKeyPressed(Keyboard::Key::J)) ToReturn.push_back('j');
		if(Keyboard::isKeyPressed(Keyboard::Key::K)) ToReturn.push_back('k');
		if(Keyboard::isKeyPressed(Keyboard::Key::L)) ToReturn.push_back('l');
		if(Keyboard::isKeyPressed(Keyboard::Key::M)) ToReturn.push_back('m');
		if(Keyboard::isKeyPressed(Keyboard::Key::N)) ToReturn.push_back('n');
		if(Keyboard::isKeyPressed(Keyboard::Key::O)) ToReturn.push_back('o');
		if(Keyboard::isKeyPressed(Keyboard::Key::P)) ToReturn.push_back('p');
		if(Keyboard::isKeyPressed(Keyboard::Key::Q)) ToReturn.push_back('q');
		if(Keyboard::isKeyPressed(Keyboard::Key::R)) ToReturn.push_back('r');
		if(Keyboard::isKeyPressed(Keyboard::Key::S)) ToReturn.push_back('s');
		if(Keyboard::isKeyPressed(Keyboard::Key::T)) ToReturn.push_back('t');
		if(Keyboard::isKeyPressed(Keyboard::Key::U)) ToReturn.push_back('u');
		if(Keyboard::isKeyPressed(Keyboard::Key::V)) ToReturn.push_back('v');
		if(Keyboard::isKeyPressed(Keyboard::Key::W)) ToReturn.push_back('w');
		if(Keyboard::isKeyPressed(Keyboard::Key::X)) ToReturn.push_back('x');
		if(Keyboard::isKeyPressed(Keyboard::Key::Y)) ToReturn.push_back('y');
		if(Keyboard::isKeyPressed(Keyboard::Key::Z)) ToReturn.push_back('z');
	}

	if(Keyboard::isKeyPressed(Keyboard::Key::Num0)) ToReturn.push_back('1');
	if(Keyboard::isKeyPressed(Keyboard::Key::Num2)) ToReturn.push_back('2');
	if(Keyboard::isKeyPressed(Keyboard::Key::Num3)) ToReturn.push_back('3');
	if(Keyboard::isKeyPressed(Keyboard::Key::Num4)) ToReturn.push_back('4');
	if(Keyboard::isKeyPressed(Keyboard::Key::Num5)) ToReturn.push_back('5');
	if(Keyboard::isKeyPressed(Keyboard::Key::Num6)) ToReturn.push_back('6');
	if(Keyboard::isKeyPressed(Keyboard::Key::Num7)) ToReturn.push_back('7');
	if(Keyboard::isKeyPressed(Keyboard::Key::Num8)) ToReturn.push_back('8');
	if(Keyboard::isKeyPressed(Keyboard::Key::Num9)) ToReturn.push_back('9');
	if(Keyboard::isKeyPressed(Keyboard::Key::Num0)) ToReturn.push_back('0');
	
	if(Keyboard::isKeyPressed(Keyboard::Key::BackSpace)) ToReturn.push_back('\b');
	if(Keyboard::isKeyPressed(Keyboard::Key::Space)) ToReturn.push_back(' ');

	return ToReturn;
}