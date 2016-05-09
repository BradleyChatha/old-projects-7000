module tk.World.Chunk;

import Common;
import jengine.graphics.camera;
import tk.Entities.Player;
import tk.World.Tiles.Tile;


enum chunkSize = 32;
enum tileSize  = 32;

/// The width of a chunk in pixels.
enum chunkWidth  = (chunkSize * tileSize);

/// The height of a chunk in pixels.
enum chunkHeight = chunkWidth;

alias ChunkMap = byte[chunkSize][chunkSize];

class Chunk
{
    ///Creates the array of sprites with all the textures depending on the passed map.
    this(Vector2i topLeftChunk, ChunkMap map)
    {
        this._topLeft = topLeftChunk;
        this.loadMap(topLeftChunk, map);
    }

    void draw()
    {
        for(int i = 0; i < chunkSize; i++)
        {
            for(int j = 0; j < chunkSize; j++)
            {
                Renderer.drawSprite(tiles[i][j].sprite);
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
        const topLeft = this._topLeft.asVector!int;
        const size    = (tileSize * chunkSize);

        return Rectangle(topLeft.x, topLeft.y, size, size).intersectsWith(player.sprite.box.box);
    }

    /++
     + Makes a position relative to the chunk.
     + For example, if the position of the chunk was (40, 60) and the position given was (140, 200), the relative position would be (100, 140).
     + 
     + Parameters:
     +  position = The position to convert.
     + 
     + Returns:
     +  $(B position) relative to the position of the chunk.
     + ++/
    @safe @nogc
    Vector2f relativePosition(Vector2f position) nothrow
    {
        return (position - this._topLeft.asVector!float);
    }

    /++
     + Returns up to 9 tiles around a point.
     + 
     + E.G.
     + {
     +      T = Tile
     +      P = Point
     +      T&P = Tile the point is over
     + 
     +      T T   T
     +      T T&P T
     +      T T   T
     + 
     +      All tiles touching the tile the point is around will be returned.
     + }
     + 
     + Parameters:
     +  point = The point to get the tiles of.
     + 
     + Returns:
     +  A static array of 9 Sprites.
     +  Some of the sprites *may* be null, so make sure to check for that.
     + ++/
    @safe @nogc
    Tile[9] tilesAroundPoint(Vector2f point) nothrow
    {
        Tile[9] toReturn;

        // Find which tile the point is over.
        auto pos  = this.relativePosition(point);
        auto cell = (pos / Vector2f(tileSize, tileSize)).asVector!int;

        @safe @nogc
        void setSprite(size_t index, int x, int y) nothrow
        {
            assert(index < toReturn.length, "Umm...?");

            // If the cell given is within a valid range.
            if(x >= 0 && x < chunkSize &&
               y >= 0 && y < chunkSize)
            {
                // Set the sprite
                toReturn[index] = this.tiles[y][x];
            }
        }

        setSprite(0, cell.x - 1, cell.y - 1); // Top left
        setSprite(1, cell.x,     cell.y - 1); // Top middle
        setSprite(2, cell.x + 1, cell.y - 1); // Top right
        setSprite(3, cell.x - 1, cell.y);     // Middle left
        setSprite(4, cell.x,     cell.y);     // Middle
        setSprite(5, cell.x + 1, cell.y);     // Middle right
        setSprite(6, cell.x - 1, cell.y + 1); // Bottom left
        setSprite(7, cell.x,     cell.y + 1); // Bottom middle
        setSprite(8, cell.x + 1, cell.y + 1); // Bottom right

        return toReturn;
    }

    /// Ditto
    @safe @nogc
    Tile[9] tilesAroundPoint(Player player) nothrow
    {
        // We want to use the player's center point for this, instead of the top-left point.
        return this.tilesAroundPoint(
            player.sprite.position + player.sprite.centre.asVector!float
            );
    }

    @property
    Vector2i topLeft()
    {
        return this._topLeft;
    }

    /++
     + I'll try to show you how it works D:
     + ++/
    @property
    Vector2i cell()
    {
        return this.topLeft / Vector2i(chunkWidth, chunkHeight);
    }

    @property
    Tile[chunkSize][chunkSize] getTiles()
    {
        return this.tiles;
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
                auto id = map[i][j];
                enforce(id < TileType.Tile_Count, "This map contains an ID that is too high.");

                tiles[i][j]                 = tileCache[id].clone();
                tiles[i][j].sprite.position = Vector2f(posX, posY);
                tiles[i][j].sprite.camera   = Camera.instance;

                posX += tileSize;
            }
            posY += tileSize;
            posX = minPosX;
        }
    }

    ///(0,0) is very left... I hope.
    Tile[chunkSize][chunkSize] tiles;

    /// The top left position of the chunk.
    Vector2i _topLeft;
}

