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
    }

    override void onHitEntity(PhysicalComponent other)
    {
    
    }

    override void onInit()
    {
        this._playerTexture = Cache.loadTexture("Assets/Entities/Player.png");
        this.sprite = Sprite.make(this._playerTexture);
        this.sprite.camera = Camera.instance;
        writeln(this.sprite.box.box.w, " ", this.sprite.box.box.h);
        this.moveableDirections[0..4] = true;
        super.onInit();
    }

    override void onUpdate(ref float gameTime)
    {
        this._actualSpeed = this._baseSpeed * gameTime;

        if(InputManager.isKeyDown(SDL_SCANCODE_W) && this.moveableDirections[up])
            this.tryMove(Vector2f(0, -this._actualSpeed), up);
        if(InputManager.isKeyDown(SDL_SCANCODE_S) && this.moveableDirections[down])
            this.tryMove(Vector2f(0, this._actualSpeed), down);
        if(InputManager.isKeyDown(SDL_SCANCODE_A) && this.moveableDirections[left])
            this.tryMove(Vector2f(-this._actualSpeed, 0), left);
        if(InputManager.isKeyDown(SDL_SCANCODE_D) && this.moveableDirections[right])
            this.tryMove(Vector2f(this._actualSpeed, 0), right);

        Camera.instance.centreOn(sprite);
<<<<<<< Updated upstream
=======

        //this.handleCollision();
>>>>>>> Stashed changes
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

    ///0 = up, 1 = left, 2 = right, 3 = down.
    bool[4] moveableDirections;

    enum up = 0;
    enum left = 1;
    enum right = 2;
    enum down = 3;

    void tryMove(Vector2f offset, int direction)
    {
        this.sprite.position += offset;
        auto tiles = ChunkHandler.tilesAroundPlayer(this);

        foreach(i, tile; tiles)
        {
            if(tile.ID == TileType.Tile_Tunnel)
                continue;

            if(direction == up)
            {
                if(i < 3 && this.isColliding(tile.sprite))
                    this.sprite.position.y = tile.sprite.position.y + tile.sprite.size.y;
            }
            else if(direction == down)
            {
                if(i > 5 && this.isColliding(tile.sprite))
                    this.sprite.position.y = tile.sprite.position.y - this.sprite.size.y;
            }
            else if(direction == left)
            {
                if((i == 0 || i == 3 || i == 6) && this.isColliding(tile.sprite))
                    this.sprite.position.x = tile.sprite.position.x + tile.sprite.size.x;
            }
            else if(direction == right)
            {
                if((i == 2 || i == 5 || i == 8) && this.isColliding(tile.sprite))
                    this.sprite.position.x = tile.sprite.position.x - this.sprite.size.x;
            }
        }
    }

    ///Checks if player is touching a certain sprite
    bool isColliding(Sprite otherSprite)
    {
        assert(this.sprite !is null, "The sprite is null. Cannot be used.");
        return this.sprite.collides(otherSprite);
    }
}

