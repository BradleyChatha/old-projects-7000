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
                ///tile < 1 && tile > 3 == Dirt
                uint tile = uniform(1, 5);

                writeln(tile);

                ///Dirt, most common.
                if(tile >= 1 && tile <= 3)
                    map[i][j] = 1;
                else if(tile >= 4)
                    map[i][j] = 2;
            }
        }

        return map;
    }
}

///Notes:
///A chunk is generated in a square around the chunk that the player is currently in.
///The new chunks are generated around the player when reaches under 11 tiles close to the edge.
///There has to be checks to ensure that it isn't recreating chunks ontop of each other.