module tk.World.Tiles.Tile;

import Common;
import tk.World.Tiles.Dirt;
import tk.World.Tiles.Stone;
import tk.World.Tiles.Tunnel;

public static Tile[512] tileCache;

/**
 * 
 * The default accessor ID is 1 for Tiles as they're blocks.
 * 
 **/
class Tile
{
public:
    this(TileType type, Texture texture)
    {
        this._ID = type;
        this._tileTexture = texture;
        this._sprite = new Sprite(this._tileTexture);
    }

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

    @property
    Sprite sprite()
    {
        return this._sprite;
    }

    ///A tile is 32 by 32 pixels.
    @property
    const uint tileSize()
    {
        return 32;
    }

    /++
     + Clones the tile.
     + ++/
    Tile clone()
    {
        return new Tile(this._ID, this._tileTexture);
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
    Sprite  _sprite;
}

enum TileType : byte
{
    Tile_Dirt = 1,
    Tile_Stone,
    Tile_Tunnel,

    /// This will have the value of the total amount of tile types <3
    Tile_Count
}

void loadTiles()
{
    tileCache[1] = new Dirt();
    tileCache[2] = new Stone();
    tileCache[3] = new Tunnel();

    // To keep things consistant, every tile in the tileCache should have the same texture size.
    // Unless, of course, you want them to have different sizes.
    foreach(t; tileCache)
    {
        if(t is null)
            break;

        assert(t.tileTexture.size == Vector2u(t.tileSize, t.tileSize));
    }
}