module tk.World.Tiles.Dirt;

import Common;

class Dirt : Tile
{
public:
    this()
    {
        this._ID = TileType.Tile_Dirt;
        this._tileTexture = Cache.loadTexture("Assets\\Tiles\\Dirt.png");
    }
}
