module tk.World.Tiles.Stone;

import Common;

class Stone : Tile
{
    this()
    {
        super(TileType.Tile_Stone, Cache.loadTexture("Assets/Tiles/Stone.png"));
    }
}

