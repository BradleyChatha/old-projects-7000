module tk.World.Map.ChunkMapGenerator;

import Common;
import tk.World.Chunk;
import std.random;

static class ChunkMapGenerator
{
public:
    this()
    {
        // Constructor code
    }

    static ChunkMap generateMap()
    {
        ChunkMap map;

        for(int i = 0; i < chunkSize; i++)
        {
            for(int j = 0; j < chunkSize; j++)
            {
                float chance = uniform(0.0f, 10.0f);

                if(chance > 3.333)
                    map[i][j] = TileType.Tile_Dirt;
                else
                    map[i][j] = TileType.Tile_Stone;
            }
        }

        return map;
    }

private:
}
