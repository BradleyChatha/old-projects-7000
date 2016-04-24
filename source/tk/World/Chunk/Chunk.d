module tk.World.Chunk;

import Common;
import jengine.graphics.camera;
import tk.Entities.Player;
import tk.World.Tiles.Tile;

enum chunkSize = 32;
enum tileSize  = 32;
alias ChunkMap = byte[chunkSize][chunkSize];

class Chunk
{
    ///Creates the array of sprites with all the textures depending on the passed map.
    this(Vector2i topLeftChunk, ChunkMap map)
    {
        this.loadMap(topLeftChunk, map);
    }

    ~this()
    {
        for(int i = 0; i < chunkSize; i++)
        {
            for(int j = 0; j < chunkSize; j++)
            {
                Sprite.dispose(tiles[i][j]);
            }
        }
    }

    void draw()
    {
        for(int i = 0; i < chunkSize; i++)
        {
            for(int j = 0; j < chunkSize; j++)
            {
                Renderer.drawSprite(tiles[i][j]);
            }
        }
    }

    /++
     + Determines if the given player is inside the chunk.
     + 
     + Parameters:
     +  player = The player to test for.
     + 
     + Returns:
     +  $(D true) if $(B point) is inside the chunk.
     +  $(D false) otherwise.
     + ++/
    @safe @nogc
    bool hasPlayer(Player player) nothrow
    {
        // Find the top-left position of the chunk
        const topLeft = this.tiles[0][0].position.asVector!int;
        const size    = (tileSize * chunkSize);

        return Rectangle(topLeft.x, topLeft.y, topLeft.x + size, topLeft.y + size).intersectsWith(player.sprite.box.box);
    }

private:

    void loadMap(Vector2i topLeftChunk, ChunkMap map)
    {
        ///The position values of the tile.
        const int minPosX = topLeftChunk.x;
        int posX = topLeftChunk.x;
        int posY = topLeftChunk.y;

        for(int i = 0; i < chunkSize; i++)
        {
            for(int j = 0; j < chunkSize; j++)
            {
                // Instead of reapeating code in that giant switch statement.
                // We can just throw an exception if the number is too high, and then assume the ID is correct after that.
                import std.exception : enforce;
                
                auto id = map[i][j];
                enforce(id < TileType.Tile_Count, "This map contains an ID that is too high.");

                tiles[i][j]        = Sprite.make(tileCache[id].tileTexture, Vector2f(posX, posY));
                tiles[i][j].camera = Camera.instance;

                posX += tileSize;
            }
            posY += tileSize;
            posX = minPosX;
        }
    }

    ///(0,0) is very left... I hope.
    Sprite[chunkSize][chunkSize] tiles;
}

