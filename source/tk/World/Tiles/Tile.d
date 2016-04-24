module tk.World.Tiles.Tile;

import Common;
import tk.World.Tiles.Dirt;
import tk.World.Tiles.Stone;

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

    ///A tile is 32 by 32 pixels.
    @property
    const uint tileSize()
    {
        return 32;
    }

    ///Finds and returns the highest tile ID in tileCache
    static uint maxID()
    {
        uint highestID = 0;

        foreach(i, t; tileCache)
        {
            if(i != 0 && t is null)
                break;
            else if(i == 0 && t is null)
                continue;

            if(highestID < t.ID)
                highestID = t.ID;

        }

        return highestID;
    }

protected:
    TileType _ID;
    Texture _tileTexture;
}

enum TileType : byte
{
    Tile_Dirt = 1,
    Tile_Stone,

    /// This will have the value of the total amount of tile types <3
    Tile_Count
}

void loadTiles()
{
    tileCache[1] = new Dirt();
    tileCache[2] = new Stone();
}