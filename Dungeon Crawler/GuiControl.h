#pragma once

#include "AssetLoader.h"

#include <SFML\System.hpp>
#include <SFML\Window.hpp>

#include <map>
#include <string>

class GuiContainer;

/// Base class used to create Gui controls
class GuiControl
{
private:
	/// The position of the Control
	sf::Vector2f	_Position;

	/// The container that is handling this control
	GuiContainer*	_Container;

protected:
	/// Returns true if the mouse is over "sprite", false otherwise.
	bool IsMouseOverSprite(sf::Sprite& sprite, sf::RenderWindow* window);

public:
	GuiControl(void);
	
	/// Using "loader", load in whatever assets the control needs
	virtual void Init(AssetLoader* loader) = 0;

	/// Using "window", draw whatever is needed to the screen
	virtual void Draw(sf::RenderWindow* window) = 0;

	/// Update the control. "window" is used for any logic that needs data of the window.
	virtual void Update(sf::RenderWindow* window) = 0;

	/// In this function, add code to reposition any of the Control's sprites using the current value of "GetPosition"
	/// This function is called then the parent container for this control has it's position changed
	virtual void Inline() = 0;

	/// Get the position of the control
	sf::Vector2f GetPosition();

	/// Get the position of the control, relative to it's container
	sf::Vector2f GetRelativePosition();

	/// Set the position of the control, relative to it's GuiContainer
	void SetPosition(sf::Vector2f vect);

	/// Set the Container that the control is used in. Can only be set once.
	void SetContainer(GuiContainer* container);

	/// Get the container that the control is used in.
	GuiContainer* GetContainer();
};

class GuiContainer
{
private:
	AssetLoader*						_Loader;
	std::map<std::string, GuiControl*>	_Controls;
	sf::Vector2f						_Position;

public:
	GuiContainer(void);
	~GuiContainer(void);

	void Init(AssetLoader* loader);
	void Draw(sf::RenderWindow* window);
	void Update(sf::RenderWindow* window);

	void AddControl(GuiControl* control, std::string id);

	/// Before you even try to point out that I put the function's code in a header file, that's what you have to do with Template functions <3.
	template<typename C>
	C* GetControl(std::string id)
	{
		return (C*)this->_Controls[id];
	}

	void SetPosition(sf::Vector2f vect);
	sf::Vector2f GetPosition();
	void Move(sf::Vector2f vect);
};