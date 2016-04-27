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
        this.chunks ~= new Chunk(Vector2i(1024,0), ChunkMapGenerator.generateMap());
        this.chunks ~= new Chunk(Vector2i(2048,0), ChunkMapGenerator.generateMap());
        this.chunks ~= new Chunk(Vector2i(3072,0), ChunkMapGenerator.generateMap());
        this.chunks ~= new Chunk(Vector2i(4096,0), ChunkMapGenerator.generateMap());
    }

    void update(Player player)
    {
        ///Check if there is a player within the current the current chunk and assign the chunk its own object
        ///I can't help but feel there is a better way than this...
        foreach(Chunk chunk; this.chunks)
        {
            if(!chunk.hasPlayer(player))
                continue;

            if(this.currentPlayerChunk !is null && this.currentPlayerChunk.hasPlayer(player))
                break;

            this.currentPlayerChunk = chunk;
        }

        assert(this.currentPlayerChunk !is null, "The player isn't inside any chunk.");

        ///Temp for testing
        //Vector2f pos = this.currentPlayerChunk.relativePosition(player.sprite.position);

        ///Top
        if(this.currentPlayerChunk.relativePosition(player.sprite.position).y <= -11)
        {
            this.chunks ~= new Chunk(Vector2i(this.currentPlayerChunk.topLeft.x, -(this.currentPlayerChunk.topLeft.y + chunkHeight)), ChunkMapGenerator.generateMap());
            writeln("New Chunk Created");
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
