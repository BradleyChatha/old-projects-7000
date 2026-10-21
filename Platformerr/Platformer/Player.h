#pragma once

#include <SFML\Graphics.hpp>
#include <fstream>
#include "Actor.h"
#include "Cache.h"

using namespace sf;
using namespace std;

class Player : Actor
{
public:
	Player();
	~Player();

	virtual void Destroy(void) override;
	virtual void Move(Vector2f MoveBy) override;
	virtual void Teleport(Vector2f NewPosition) override;
	virtual void Update(Time DeltaTime) override;
	virtual void draw(RenderWindow &GameWindow) override;
	virtual void Save(fstream &SaveFile) override;
	virtual void Load(fstream &SaveFile) override;

private:
	float PlayerMovementSpeed;
};

