module tk.World.Tiles.Stone;

import Common;

class Stone : Tile
{
    this()
    {
        this._ID = TileType.Tile_Stone;
        this._tileTexture = Cache.loadTexture("Assets\\Tiles\\Stone.png");
    }
}

