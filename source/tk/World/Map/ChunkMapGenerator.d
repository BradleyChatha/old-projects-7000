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
                // 75% chance of dirt
                auto dirt = randomBool(0.75);

                if(dirt)
                    map[i][j] = TileType.Tile_Dirt;
                else
                    map[i][j] = TileType.Tile_Stone;
            }
        }

        return map;
    }

private:

    /++
     + Generates a random boolean, with a certain probability of being true.
     + 
     + Parameters:
     +  probability = The probability of returning $(D true). Must be between 0 and 1.
     + 
     + Returns:
     +  Either true or false. 
     + ++/
    static bool randomBool(float probability)
    {
        if(probability < 0)
            probability = 0;
        else if(probability > 1.0)
            probability = 1.0;

        auto result = uniform(0.0f, 1.0f);

        return (result < probability);
    }
}

///Notes:
///A chunk is generated in a square around the chunk that the player is currently in.
///The new chunks are generated around the player when reaches under 11 tiles close to the edge.
///There has to be checks to ensure that it isn't recreating chunks ontop of each other.