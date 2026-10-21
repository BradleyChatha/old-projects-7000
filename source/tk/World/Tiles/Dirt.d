module tk.World.Tiles.Dirt;

import Common;

class Dirt : Tile
{
public:
    this()
    {
        super(TileType.Tile_Dirt, Cache.loadTexture("Assets\\Tiles\\Dirt.png"));
    }
}
