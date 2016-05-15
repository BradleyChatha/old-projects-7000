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
            this.sprite.position += Vector2f(0, -this._actualSpeed);
        if(InputManager.isKeyDown(SDL_SCANCODE_S) && this.moveableDirections[down])
            this.sprite.position += Vector2f(0, this._actualSpeed);
        if(InputManager.isKeyDown(SDL_SCANCODE_A) && this.moveableDirections[left])
            this.sprite.position += Vector2f(-this._actualSpeed, 0);
        if(InputManager.isKeyDown(SDL_SCANCODE_D) && this.moveableDirections[right])
            this.sprite.position += Vector2f(this._actualSpeed, 0);

        Camera.instance.centreOn(sprite);

        this.handleCollision();
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

    ///Checks if player is touching a certain sprite
    bool isColliding(Sprite otherSprite)
    {
        assert(this.sprite !is null, "The sprite is null. Cannot be used.");
        return this.sprite.collides(otherSprite);
    }

    ///Handles whether the tile that is being touched is a tile that can't be walked through
    void handleCollision()
    {                
        auto c = ChunkHandler.tilesAroundPlayer(this);
        int index = 0;
        foreach(tile; c)
        {
            assert(tile !is null, "The tile has some how became null again, black magic!");

            if(tile.sprite.collides(this.sprite))
            {
                /+
                ///Debug
                final switch(tile.ID)
                {
                    case TileType.Tile_Dirt:
                        writeln("Tile type: Dirt");
                        break;
                    case TileType.Tile_Stone:
                        writeln("Tile type: Stone");
                        break;
                    case TileType.Tile_Tunnel:
                        writeln("Tile type: Tunnel");
                }
                ///
                +/

                if(tile.ID == TileType.Tile_Tunnel)
                {
                    ///Up Left
                    if(index == 0)
                    {
                        this.moveableDirections[up] = true;
                        this.moveableDirections[left] = true;
                    }
                    ///Up Mid
                    if(index == 1)
                    {
                        this.moveableDirections[up] = true;
                    }
                    ///Up Right
                    if(index == 2)
                    {
                        this.moveableDirections[up] = true;
                        this.moveableDirections[right] = true;
                    }
                    ///Mid left
                    if(index == 3)
                    {
                        this.moveableDirections[left] = true;
                    }
                    ///Mid right
                    if(index == 5)
                    {
                        this.moveableDirections[right] = true;
                    }
                    ///Down Left
                    if(index == 6)
                    {
                        this.moveableDirections[down] = true;
                        this.moveableDirections[left] = true;
                    }
                    ///Down Down
                    if(index == 7)
                    {
                        this.moveableDirections[down] = true;
                    }
                    ///Down Right
                    if(index == 8)
                    {
                        this.moveableDirections[down] = true;
                        this.moveableDirections[right] = true;
                    }
                }
                else
                {
                    ///Up Left
                    if(index == 0)
                    {
                        this.moveableDirections[up] = false;
                        this.moveableDirections[left] = false;
                        this.sprite.position = Vector2f(tile.sprite.position.x + cast(float)(tile.sprite.size.x), tile.sprite.position.y + cast(float)(tile.sprite.size.y));
                    }
                    ///Up Mid
                    if(index == 1)
                    {
                        this.moveableDirections[up] = false;
                        this.sprite.position.y = (tile.sprite.position.y + cast(float)(tile.sprite.size.y));
                    }
                    ///Up Right
                    if(index == 2)
                    {
                        this.moveableDirections[up] = false;
                        this.moveableDirections[right] = false;
                        this.sprite.position = Vector2f(tile.sprite.position.x - cast(float)(tile.sprite.size.x), tile.sprite.position.y + cast(float)(tile.sprite.size.y));
                    }
                    ///Mid left
                    if(index == 3)
                    {
                        this.moveableDirections[left] = false;
                    }
                    ///Mid right
                    if(index == 5)
                    {
                        this.moveableDirections[right] = false;
                    }
                    ///Down Left
                    if(index == 6)
                    {
                        this.moveableDirections[down] = false;
                        this.moveableDirections[left] = false;
                    }
                    ///Down Down
                    if(index == 7)
                    {
                        this.moveableDirections[down] = false;
                    }
                    ///Down Right
                    if(index == 8)
                    {
                        this.moveableDirections[down] = false;
                        this.moveableDirections[right] = false;
                    }
                }
            }
            index++;
        }
    }
}

