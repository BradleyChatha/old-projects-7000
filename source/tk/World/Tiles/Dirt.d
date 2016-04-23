module tk.World.Tiles.Dirt;

import Common;
import tk.World.Tiles.Tile;

class Dirt : Tile
{
public:
    this()
    {
        this._ID = 1;
        this._tileTexture = Cache.loadTexture("Assets\\Tiles\\Dirt.png");
    }
}
