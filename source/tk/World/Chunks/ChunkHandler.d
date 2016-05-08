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
        this.chunks[0][0] = new Chunk(Vector2i(0,0), ChunkMapGenerator.generateMap());
    }

    void update(Player player)
    {
        auto array = chunksAroundPlayer(player);
        foreach(Chunk* chunk; array)
        {
            if(chunk is null || !chunk.hasPlayer(player))
                continue;

            /*if(this.currentPlayerChunk !is null && this.currentPlayerChunk.hasPlayer(player))
                break;*/


            if(chunk.hasPlayer(player))
                this.currentPlayerChunk = *chunk;
        }

        writeln("Chunks: ", this.chunks.length);

        assert(this.currentPlayerChunk !is null, "The player isn't inside any chunk.");

        ///Temp for testing
        //Vector2f pos = this.currentPlayerChunk.relativePosition(player.sprite.position);

        createChunk(this.currentPlayerChunk);
    }

    void draw(Player player)
    {
        auto array = chunksAroundPlayer(player);
        foreach(Chunk* c; array)
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
    Tile[18] tilesAroundPlayer(Player player)
    {
        Chunk[9] chunks;
        Tile[18] toReturn;

        size_t index = 0;
        auto cell = (player.sprite.position / Vector2f(chunkWidth, chunkHeight)).asVector!int;
        foreach(i; -1..2)
        {
            foreach(j; -1..2)
            {
                chunks[index++] = this.chunks[cell.x + i][cell.y + j];
            }
        }

        index = 0;
        foreach(c; chunks)
        {
            if(c is null)
                continue;

            foreach(tile; c.tilesAroundPoint(player))
            {
                if(tile !is null)
                    toReturn[index++] = tile;
            }
        }

        return toReturn;
    }

    Chunk[4] getPlayerChunks(Player player)
    {
        Chunk[4] toReturn;
        auto cell = (player.sprite.position / Vector2f(chunkWidth, chunkHeight)).asVector!int;

        size_t index = 0;

        ///Top-Left
        if(this.chunks[cell.x - 1][cell.y - 1].hasPlayer(player))
            toReturn[index++] = this.chunks[cell.x - 1][cell.y - 1];
        ///Top-Middle
        if(this.chunks[cell.x][cell.y - 1].hasPlayer(player))
            toReturn[index++] = this.chunks[cell.x][cell.y - 1];
        ///Top-Right
        if(this.chunks[cell.x + 1][cell.y - 1].hasPlayer(player))
            toReturn[index++] = this.chunks[cell.x + 1][cell.y - 1];
        ///Middle-Left
        if(this.chunks[cell.x - 1][cell.y].hasPlayer(player))
            toReturn[index++] = this.chunks[cell.x - 1][cell.y];
        ///Middle-Middle
        if(this.chunks[cell.x][cell.y].hasPlayer(player))
            toReturn[index++] = this.chunks[cell.x][cell.y];
        ///Middle-Right
        if(this.chunks[cell.x + 1][cell.y].hasPlayer(player))
            toReturn[index++] = this.chunks[cell.x + 1][cell.y];
        ///Bottom-Left
        if(this.chunks[cell.x - 1][cell.y + 1].hasPlayer(player))
            toReturn[index++] = this.chunks[cell.x - 1][cell.y + 1];
        ///Bottom-Middle
        if(this.chunks[cell.x][cell.y + 1].hasPlayer(player))
            toReturn[index++] = this.chunks[cell.x][cell.y + 1];
        ///Bottom-Right
        if(this.chunks[cell.x + 1][cell.y + 1].hasPlayer(player))
            toReturn[index++] = this.chunks[cell.x + 1][cell.y + 1];

        return toReturn;
    }

private:
    static Chunk[int][int] chunks; // So something like, Chunk[int][int]? >:D Go for it. And pray the GC doesn't have a fit for some reason
    ///The chunk which currently has player
    static Chunk currentPlayerChunk; 

    static Chunk*[5*5] chunksAroundPlayer(Player player)
    {
        auto cell = (player.sprite.position / Vector2f(chunkWidth, chunkHeight)).asVector!int;

        Chunk* get(int x, int y)
        {
            auto first = (cell.x + x in this.chunks);
            
            if(first !is null)
            {
                auto second = (cell.y + y in *first);
                
                return second;
            }
            else
                return null;
        }
        Chunk*[5*5] array;
        size_t index = 0;
        foreach(x; -2..3)
        {
            foreach(y; -2..3)
            {
                array[index++] = get(x, y);
            }
        }

        return array;
    }

    ///Will make up, down, left, right, if not found.
    static void createChunk(Chunk centreChunk)
    {
        //Chunk tempChunk = null; //bby
        auto cell = centreChunk.cell;

        ///Bradley and his nested functions
        ///Finds a chunk or doesn't. COMMENTING POWER
        Chunk* getChunk(Vector2i cell)
        {
            auto first = (cell.x in this.chunks);

            if(first !is null)
            {
                auto second = (cell.y in *first);

                return second;
            }
            else
                return null;
        }

        // Up
        auto temp = getChunk(cell + Vector2i(0, -1));
        if(temp is null)
        {
            auto next     = new Chunk(Vector2i(centreChunk.topLeft.x, (centreChunk.topLeft.y - chunkHeight)), ChunkMapGenerator.generateMap());
            auto nextCell = next.cell;
            assert(nextCell.x == cell.x && nextCell.y == cell.y - 1); // This makes sure it's 1 cell above

            this.chunks[nextCell.x][nextCell.y] = next;
        }

        // Down
        temp = getChunk(cell + Vector2i(0, 1));
        if(temp is null) // We can't use centreChunk.down anymore
        {
            auto next = new Chunk(Vector2i(centreChunk.topLeft.x, (centreChunk.topLeft.y + chunkHeight)), ChunkMapGenerator.generateMap());
            auto nextCell = next.cell;
            assert(nextCell.x == cell.x && nextCell.y == cell.y + 1); // This assert makes sure that the new chunk is 1 cell down than the centreChunk.
            
            this.chunks[nextCell.x][nextCell.y] = next;
        }

        // Left
        temp = getChunk(cell + Vector2i(-1, 0));
        if(temp is null)
        {
            auto next = new Chunk(Vector2i((centreChunk.topLeft.x - chunkWidth), centreChunk.topLeft.y), ChunkMapGenerator.generateMap());
            auto nextCell = next.cell;
            assert(nextCell.x == cell.x - 1 && nextCell.y == cell.y);

            this.chunks[nextCell.x][nextCell.y] = next;
        }

        // Right
        temp = getChunk(cell + Vector2i(1, 0));
        if(temp is null)
        {
            auto next = new Chunk(Vector2i((centreChunk.topLeft.x + chunkWidth), centreChunk.topLeft.y), ChunkMapGenerator.generateMap());
            auto nextCell = next.cell;
            assert(nextCell.x == cell.x + 1 && nextCell.y == cell.y);
            
            this.chunks[nextCell.x][nextCell.y] = next;
        }

        /// Top-Left
        temp = getChunk(cell + Vector2i(-1, -1));
        if(temp is null)
        {
            auto next     = new Chunk(Vector2i((centreChunk.topLeft.x - chunkWidth), (centreChunk.topLeft.y - chunkHeight)), ChunkMapGenerator.generateMap());
            auto nextCell = next.cell;
            assert(nextCell.x == cell.x - 1 && nextCell.y == cell.y - 1); // This makes sure it's 1 cell above
            
            this.chunks[nextCell.x][nextCell.y] = next;
        }

        // Top Right
        temp = getChunk(cell + Vector2i(1, -1));
        if(temp is null)
        {
            auto next     = new Chunk(Vector2i((centreChunk.topLeft.x + chunkWidth), (centreChunk.topLeft.y - chunkHeight)), ChunkMapGenerator.generateMap());
            auto nextCell = next.cell;
            assert(nextCell.x == cell.x + 1 && nextCell.y == cell.y - 1); // This makes sure it's 1 cell above
            
            this.chunks[nextCell.x][nextCell.y] = next;
        }

        // Bottom left
        temp = getChunk(cell + Vector2i(-1, 1));
        if(temp is null)
        {
            auto next = new Chunk(Vector2i((centreChunk.topLeft.x - chunkWidth), (centreChunk.topLeft.y + chunkHeight)), ChunkMapGenerator.generateMap());
            auto nextCell = next.cell;
            assert(nextCell.x == cell.x - 1 && nextCell.y == cell.y + 1);
            
            this.chunks[nextCell.x][nextCell.y] = next;
        }

        // Bottom right
        temp = getChunk(cell + Vector2i(1, 1));
        if(temp is null)
        {
            auto next = new Chunk(Vector2i((centreChunk.topLeft.x + chunkWidth), (centreChunk.topLeft.y + chunkHeight)), ChunkMapGenerator.generateMap());
            auto nextCell = next.cell;
            assert(nextCell.x == cell.x + 1 && nextCell.y == cell.y + 1);
            
            this.chunks[nextCell.x][nextCell.y] = next;
        }
    }
}
/+
 + e_e If you want me to code it, sure.
 + 
 + But we have an array as usual
 + Chunk[] chunks;
 + 
 + It *can*, but I'm not sure if it'll be slow. We can try <3
 + ++/