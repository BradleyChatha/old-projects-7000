#pragma once

#include <SFML\Graphics.hpp>
#include <vector>

#include "Actor.h"
#include "Cache.h"

using namespace std;
using namespace sf;

class Level
{
public:
	Level();
	~Level();

private:
	///All of the objects in the scene, interactables and player/AI.
	vector<Actor> SceneObjects;
	///The ground that can be walked on.
	Sprite Ground;
	///The 'Skybox'
	Sprite Sky;
	///The level name.
	string LevelName;
};

