module tk.World.Tiles.Tunnel;

import Common;
import tk.World.Tiles.Tile;

class Tunnel : Tile
{
    this()
    {
        super(TileType.Tile_Tunnel, Cache.loadTexture("Assets\\Tiles\\Tunnel.png"));
    }
}

