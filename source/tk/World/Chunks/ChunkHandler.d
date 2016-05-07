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
        ///Check if there is a player within the current the current chunk and assign the chunk its own object
        ///I can't help but feel there is a better way than this...
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

    void draw()
    {
        foreach(array; this.chunks)
        {
            foreach(Chunk c; array)
            {
                c.draw();
            }
        }
    }

private:
    static Chunk[int][int] chunks; // So something like, Chunk[int][int]? >:D Go for it. And pray the GC doesn't have a fit for some reason
    ///The chunk which currently has player
    static Chunk currentPlayerChunk; 

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