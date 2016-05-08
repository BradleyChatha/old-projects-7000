module tk.Entities.Player;

import Common;
import jengine.graphics.camera;
import std.stdio;
import tk.World.Chunks.ChunkHandler;
import tk.World.Chunk;

class Player : PhysicalComponent 
{
public:
    this()
    {
        this.moveableDirections[0..3] = true;
    }

    override void onHitEntity(PhysicalComponent other)
    {
    
    }

    override void onInit()
    {
        this._playerTexture = Cache.loadTexture("Assets/Entities/Player.png");
        this.sprite = Sprite.make(this._playerTexture);
        this.sprite.camera = Camera.instance;
        super.onInit();
    }

    override void onUpdate(ref float gameTime)
    {
        this._actualSpeed = this._baseSpeed * gameTime;

        if(InputManager.isKeyDown(SDL_SCANCODE_W) && this.moveableDirections[0])
            this.sprite.position += Vector2f(0, -this._actualSpeed);
        if(InputManager.isKeyDown(SDL_SCANCODE_S) && this.moveableDirections[1])
            this.sprite.position += Vector2f(0, this._actualSpeed);
        if(InputManager.isKeyDown(SDL_SCANCODE_A) && this.moveableDirections[2])
            this.sprite.position += Vector2f(-this._actualSpeed, 0);
        if(InputManager.isKeyDown(SDL_SCANCODE_D) && this.moveableDirections[3])
            this.sprite.position += Vector2f(this._actualSpeed, 0);

        Camera.instance.centreOn(sprite);
    }

    override bool onEvent(SDL_Event event, bool handled)
    {
        return false;
    }

    override void onUninit()
    {
        super.onUninit();
    }


private:
    Texture _playerTexture;
    float _baseSpeed = 150.0f;
    float _actualSpeed;

    ///0 = up, 1 = right, 2 = down, 3 = left
    bool[4] moveableDirections;

    ///Checks if player is touching a certain sprite
    bool isColliding(Sprite otherSprite)
    {
        assert(this.sprite !is null, "The sprite is null. Cannot be used.");
        return this.sprite.collides(otherSprite);
    }

    ///Handles whether the tile that is being touched is a tile that can't be walked through
    void handleCollision()
    {
        auto chunks = ChunkHandler.getPlayerChunks(this);

        foreach(chunk; chunks)
        {
            if(chunk is null)
                continue;
                
            auto c = ChunkHandler.tilesAroundPoint(this);
            foreach(tile; c)
            {
                if(tile.collides(this.sprite))
                    return true;
            }
        }

        return false;
    }
}

