#pragma once
class Map
{
public:
	Map(unsigned int, unsigned int, unsigned int);
	void getMapSize(unsigned int&, unsigned int&);
	char* getMap(void);

private:
	unsigned int sizeX;
	unsigned int sizeY;
	unsigned int zone;

	char* map;
};

