module tk.World.Tiles.Tile;

import Common;
import tk.World.Tiles.Dirt;

public static Tile[512] tileCache;

/**
 * 
 * The default accessor ID is 1 for Tiles as they're blocks.
 * 
 **/
class Tile
{
public:
    @property
    uint ID()
    {
        return this._ID;
    }

    @property
    Texture tileTexture()
    {
        return this._tileTexture;
    }

protected:
    uint _ID;
    Texture _tileTexture;
}

void loadTiles()
{
    tileCache[1] = new Dirt();
}