#include "GuiControl.h"
#include <iostream>
#include <cstdlib>

using namespace sf;
using namespace std;

GuiControl::GuiControl(void) : _Position(0, 0), _Container(nullptr)
{
}

/// Get the position of the control
Vector2f GuiControl::GetPosition()
{
	return this->_Position;
}

Vector2f GuiControl::GetRelativePosition()
{
	return this->_Position - this->_Container->GetPosition();
}

/// Set the position of the control
void GuiControl::SetPosition(Vector2f vect)
{
	this->_Position = vect + this->_Container->GetPosition();
	this->Inline();
}

/// Set the Container that the control is used in. Can only be set once.
void GuiControl::SetContainer(GuiContainer* container)
{
	// If we've already set the container, just return.
	if(this->_Container != nullptr)
	{
		return;
	}

	this->_Container = container;
}

/// Get the container that the control is used in.
GuiContainer* GuiControl::GetContainer()
{
	return this->_Container;
}

/// Returns true if the mouse is over "sprite", false otherwise.
bool GuiControl::IsMouseOverSprite(Sprite& sprite, RenderWindow* window)
{
	Vector2i MousePos = Mouse::getPosition(*window);
	Vector2f SpritePos = sprite.getPosition();
	Vector2u SpriteSize = sprite.getTexture()->getSize();

	//std::cout << MousePos.x << " "<< MousePos.y << " " << SpritePos.x << " " << SpritePos.y << " " << SpriteSize.x << " " << SpriteSize.y << std::endl;
	//printf("0x%X\0", SpriteSize.x);
	return (
		(MousePos.x >= SpritePos.x) && (MousePos.x <= (SpritePos.x + SpriteSize.x)) &&
		(MousePos.y >= SpritePos.y) && (MousePos.y <= (SpritePos.y + SpriteSize.y))
		);
}







GuiContainer::GuiContainer(void) {}
GuiContainer::~GuiContainer(void) 
{
	/// Free all of the controls(The GuiContainer isn't intended to share controls, so they should all be unique to a single container)
	for(auto Iter = this->_Controls.begin(); Iter != this->_Controls.end(); ++Iter)
	{
		delete Iter->second;
	}
}

void GuiContainer::Init(AssetLoader* loader)
{
	// Keep a pointer to the AssetLoader, because we're gonna need to give this to the controls we add
	this->_Loader = loader;
}

void GuiContainer::Draw(RenderWindow* window)
{
	// Draw all of the controls
	for(auto Iter = this->_Controls.begin(); Iter != this->_Controls.end(); ++Iter)
	{
		Iter->second->Draw(window);
	}
}

void GuiContainer::Update(RenderWindow* window)
{
	// Update all of the controls
	for(auto Iter = this->_Controls.begin(); Iter != this->_Controls.end(); ++Iter)
	{
		Iter->second->Update(window);
	}
}

void GuiContainer::AddControl(GuiControl* control, string id)
{
	// Setup the control then add it to our map
	control->Init(this->_Loader);
	control->SetContainer(this);
	this->_Controls[id] = control;
}

void GuiContainer::SetPosition(Vector2f vect)
{
	// We need to keep our old position so we can subtract it from the position of every control.
	// We do this because Iter->second->GetPosition() doesn't return the relative position(And we can't get it outside of the loop) so we subtract OldPos from GetPosition() to get the relative position of the control, the control should then align itself properly.
	auto OldPos = this->_Position;
	this->_Position = vect;

	// Make sure every control in this container has their position updated
	for(auto Iter = this->_Controls.begin(); Iter != this->_Controls.end(); ++Iter)
	{
		Iter->second->SetPosition(Iter->second->GetPosition() - OldPos);
		Iter->second->Inline();
	}
}

Vector2f GuiContainer::GetPosition()
{
	return this->_Position;
}

void GuiContainer::Move(sf::Vector2f vect)
{
	this->SetPosition(this->GetPosition() + vect);
}