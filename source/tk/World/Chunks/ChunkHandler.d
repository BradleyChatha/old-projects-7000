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
        this.chunks ~= new Chunk(Vector2i(0,0), ChunkMapGenerator.generateMap());
    }

    void update(Player player)
    {
        ///Check if there is a player within the current the current chunk and assign the chunk its own object
        ///I can't help but feel there is a better way than this...
        foreach(Chunk chunk; this.chunks)
        {
            if(!chunk.hasPlayer(player))
                continue;

            /*if(this.currentPlayerChunk !is null && this.currentPlayerChunk.hasPlayer(player))
                break;*/


            if(chunk.hasPlayer(player))
                this.currentPlayerChunk = chunk;
        }

        writeln("Chunks: ", this.chunks.length);

        assert(this.currentPlayerChunk !is null, "The player isn't inside any chunk.");

        ///Temp for testing
        //Vector2f pos = this.currentPlayerChunk.relativePosition(player.sprite.position);

        if(this.currentPlayerChunk.up is null)
        {
            this.chunks ~= new Chunk(Vector2i(this.currentPlayerChunk.topLeft.x, (this.currentPlayerChunk.topLeft.y - chunkHeight)), ChunkMapGenerator.generateMap());
            this.currentPlayerChunk.up = this.chunks[$ - 1];
            this.chunks[$ - 1].down = this.currentPlayerChunk; 

            if(this.currentPlayerChunk.up.left is null)
            {
                this.chunks ~= new Chunk(Vector2i((this.currentPlayerChunk.topLeft.x - chunkWidth), (this.currentPlayerChunk.topLeft.y - chunkHeight)), ChunkMapGenerator.generateMap());
                this.currentPlayerChunk.up = this.chunks[$ - 1];
            }
            if(this.currentPlayerChunk.up.right is null)
            {
                this.chunks ~= new Chunk(Vector2i((this.currentPlayerChunk.topLeft.x - chunkWidth), (this.currentPlayerChunk.topLeft.y - chunkHeight)), ChunkMapGenerator.generateMap());
                this.currentPlayerChunk.up = this.chunks[$ - 1];
            }
        }
        if(this.currentPlayerChunk.down is null)
        {
            this.chunks ~= new Chunk(Vector2i(this.currentPlayerChunk.topLeft.x, (this.currentPlayerChunk.topLeft.y + chunkHeight)), ChunkMapGenerator.generateMap());
            this.currentPlayerChunk.down = this.chunks[$ - 1];
            this.chunks[$ - 1].up = this.currentPlayerChunk;
        }
        if(this.currentPlayerChunk.left is null)
        {
            this.chunks ~= new Chunk(Vector2i((this.currentPlayerChunk.topLeft.x - chunkWidth), this.currentPlayerChunk.topLeft.y), ChunkMapGenerator.generateMap());
            this.currentPlayerChunk.left = this.chunks[$ - 1];
            this.chunks[$ - 1].right = this.currentPlayerChunk;
        }
        if(this.currentPlayerChunk.right is null)
        {
            this.chunks ~= new Chunk(Vector2i((this.currentPlayerChunk.topLeft.x + chunkWidth), this.currentPlayerChunk.topLeft.y), ChunkMapGenerator.generateMap());
            this.currentPlayerChunk.right = this.chunks[$ - 1];
            this.chunks[$ - 1].left = this.currentPlayerChunk;
        }

    }

    void draw()
    {
        foreach(Chunk c; chunks)
        {
            c.draw();
        }
    }

private:
    static Chunk[] chunks;
    ///The chunk which currently has player
    static Chunk currentPlayerChunk; 
}
