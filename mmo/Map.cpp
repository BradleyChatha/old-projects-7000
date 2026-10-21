#include "Map.h"
#include <stdlib.h>

Map::Map(unsigned int newZone, unsigned int x, unsigned int y) : zone(newZone), sizeX(x), sizeY(y), map((char*)malloc((sizeX * sizeY)+1))
{
	///Empty
}

void Map::getMapSize(unsigned int& x, unsigned int& y)
{
	x = sizeX;
	y = sizeY;
}

char* Map::getMap(void)
{
	return map;
}
