#pragma once
#include <SFML\Graphics.hpp>
#include <fstream>

using namespace std;
using namespace sf;

#define ACTOR_END_FLAG 0x00

class Actor
{
public:
	virtual void Destroy(void) = 0;
	virtual void Move(Vector2f MoveBy) = 0;
	virtual void Teleport(Vector2f NewPosition) = 0;
	virtual void Update(Time DeltaTime) = 0;
	virtual void draw(RenderWindow &GameWindow) = 0;
	virtual void Save(fstream& FileSave) = 0;
	virtual void Load(fstream& FileSave) = 0;

	unsigned int ActorID;
protected:
	bool IsAlive;
	bool IsTimer;
	Clock LifeTime;
	Sprite ActorSprite;
};

