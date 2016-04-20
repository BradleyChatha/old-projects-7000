module tk.World.World;

import std.random;
import Common;

class World
{
public:
    this()
    {

    }

private:
    Random rgn;
}

class Dirt : Tile
{
    this()
    {
        super(0);
    }

  
}