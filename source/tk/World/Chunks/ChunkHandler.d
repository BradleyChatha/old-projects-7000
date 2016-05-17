module tk.World.Chunks.ChunkHandler;

import Common;
import tk.World.Chunk;
import tk.Entities.Player;
import tk.World.Map.ChunkMapGenerator;

class ChunkHandler
{
public static:
    void setup()
    {
        ChunkHandler.createChunk(Vector2i(0, 0));
    }

    void update(Player player)
    {
        ChunkHandler.createChunk(ChunkHandler.toChunkCell(player));

        // Find the chunk the player is inside.
        auto array = getPlayerChunks(player);
        foreach(Chunk chunk; array)
        {
            if(chunk is null || !chunk.hasPlayer(player))
                continue;

            if(chunk.hasPlayer(player))
                this.currentPlayerChunk = chunk;
        }

        assert(this.currentPlayerChunk !is null, "The player isn't inside any chunk.");
    }

    void draw(Player player)
    {
        auto array = getPlayerChunks(player);
        foreach(Chunk c; array)
        {
            if(c is null)
                continue;

            c.draw();
        }
    }

    /++
     + Gets the tiles around the player, regardless if they're in different chunks.
     + 
     + Parameters:
     +  player = The player.
     + 
     + Returns:
     +  A 3x3 grid of all the tiles around the player.
     + 
     +  {
     +     0    1        2
     +     3    4&Player 5
     +     6    7        8
     +  }
     + ++/
    Tile[9] tilesAroundPlayer(Player player)
    {
        Tile[9] toReturn;
        auto cell = ChunkHandler.toTileCell(player);

        size_t index = 0;
        foreach(y; -1..2)
        {
            foreach(x; -1..2)
                toReturn[index++] = ChunkHandler.tileAtGrid(cell + Vector2i(x, y));
        }

        //toReturn[0] = ChunkHandler.tileAtGrid(cell + Vector2i(0, -1));
        return toReturn;
    }

    /++
     + Gets the chunks around the player.
     + 
     + Parameters:
     +  player = The player.
     + 
     + Returns:
     +  A 3x3 of all the chunks around the player, with the middle chunk being the player's chunk.
     + ++/
    Chunk[9] getPlayerChunks(Player player)
    {
        Chunk[9] toReturn;
        auto cell = ChunkHandler.toChunkCell(player);

        size_t index = 0;
        foreach(y; -1..2)
        {
            foreach(x; -1..2)
                toReturn[index++] = ChunkHandler.chunkAtGrid(cell + Vector2i(x, y));
        }

        return toReturn;
    }

    /++
     + Sets a chunk.
     + 
     + Parameters:
     +  x = The x position of the chunk.
     +  y = The y position of the chunk.
     +  chunk = The chunk to set.
     + ++/
    void setChunk(int x, int y, Chunk chunk)
    {
        ChunkHandler.chunks[y][x] = chunk;
    }

    /++
     + Gets a chunk at a specific coordinate. Returns null if the chunk doesn't exist
     + 
     + Parameters:
     +  coord = The coordinates of the chunk to get. This is to be used for the Chunk-grid.
     + 
     + Returns:
     +  The chunk, if it exists.
     +  $(D null) if it doesn't.
     + ++/
    Chunk chunkAtGrid(Vector2i coord)
    {
        auto first  = ChunkHandler.chunks.get(coord.y, null);
        auto second = (first is null) ? null : first.get(coord.x, null);
        
        return second;
    }

    /++
     + Calculates the chunk-grid coordinates of the given world coordinates, and returns the chunk the coord is inside.
     + 
     + Parameters:
     +  coord = The coordinate of the chunk. This is a world-position.
     + 
     + Returns:
     +  The chunk that $(B coord) is inside.
     +  Or null, if that chunk doesn't exist.
     + ++/
    Chunk chunkAt(Vector2f coord)
    {
        auto newCoord = (coord / Vector2f(chunkWidth, chunkHeight));

        if(coord.x < 0 && (coord.x % chunkWidth) != 0)
            newCoord.x -= 1;
        if(coord.y < 0 && (coord.y % chunkHeight) != 0)
            newCoord.y -= 1;

        return ChunkHandler.chunkAtGrid(newCoord.asVector!int);
    }

    /++
     + Converts a given world-position coordinate into a tile-grid coordinate, and returns the tile the coord is inside.
     + 
     + Parameters:
     +  coord = The coordinate of the tile. This is a world-position.
     + 
     + Returns:
     +  The tile that $(B coord) is inside.
     +  Or null, if for some reason the tile can't be found.
     + ++/
    Tile tileAt(Vector2f coord)
    {
        // Find the chunk the tile should be inside.
        auto chunk = ChunkHandler.chunkAt(coord);

        if(chunk is null)
            return null;

        // Then try to get the tile from inside the chunk.
        auto chunkPos = chunk.topLeft.asVector!float;

        auto cell = ((coord - chunkPos) / Vector2f(tileSize, tileSize)).asVector!int;
        /++if(cell.x == 32 || cell.y == 32)
        {
            if(cell.x == 32) coord.x += 1;
            if(cell.y == 32) coord.y += 1;

            return ChunkHandler.tileAt(coord);
        }++/

        //writefln("coord: %s | chunkPos: %s | cell: %s | chunkPosReal: %s", coord, chunkPos, cell, chunk.topLeft);

        return chunk.getTiles[cell.y][cell.x];
    }

    /// Ditto
    Tile tileAtGrid(Vector2i coord)
    {
        coord *= Vector2i(tileSize, tileSize);
        return ChunkHandler.tileAt(coord.asVector!float);
    }

    /++
     + Calculates the chunk-cell the player is inside.
     + 
     + Parameters:
     +  player = The player.
     + 
     + Returns:
     +  A Vector2i containing the cell that the player is in. This cell is for the Chunk grid.
     + ++/
    Vector2i toChunkCell(Player player)
    {
        return ChunkHandler.toChunkCell(player.sprite.position + player.sprite.centre.asVector!float);
    }

    /// Ditto
    Vector2i toChunkCell(Vector2f coord)
    {
        if(coord.y < 0)
            coord.y += -chunkHeight;
        if(coord.x < 0)
            coord.x += -chunkWidth;

        return (coord / Vector2f(chunkWidth, chunkHeight)).asVector!int;
    }

    /++
     + Calculates the tile-cell the player is inside.
     + 
     + Parameters:
     +  player = The player.
     + 
     + Returns:
     +  A Vector2i containing the cell the player is in. This cell is for the Tile grid.
     + ++/
    Vector2i toTileCell(Player player)
    {
        return ChunkHandler.toTileCell(player.sprite.position + player.sprite.centre.asVector!float);
    }

    /// Ditto
    Vector2i toTileCell(Vector2f coord)
    {
        if(coord.y < 0)
            coord.y += -tileSize;
        if(coord.x < 0)
            coord.x += -tileSize;

        return (coord / Vector2f(tileSize, tileSize)).asVector!int;
    }

private static:
    Chunk[int][int] chunks; // So something like, Chunk[int][int]? >:D Go for it. And pray the GC doesn't have a fit for some reason
    ///The chunk which currently has player
    Chunk currentPlayerChunk;

    /++
     + Will create a 3x3 grd of chunks around the given chunk, if chunks don't already exist.
     + 
     + Parameters:
     +  chunk = The chunk that is the centre of the grid. If the chunk doesn't exist, then the chunk itself is also created.
     + ++/
    void createChunk(Vector2i chunk)
    {
        foreach(y; -1..2)
        {
            foreach(x; -1..2)
            {
                auto cell     = (chunk + Vector2i(x, y));
                auto position = (cell * Vector2i(chunkWidth, chunkHeight));

                if(ChunkHandler.chunkAtGrid(cell) is null)
                    ChunkHandler.chunks[cell.y][cell.x] = new Chunk(position, ChunkMapGenerator.generateMap());
            }
        }
    }
}