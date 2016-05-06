module tk.Entities.Player;

import Common;
import jengine.graphics.camera;
import std.stdio;

import tk.World.Chunk;

class Player : PhysicalComponent 
{
public:
    this()
    {
    }

public override:

    void onHitEntity(PhysicalComponent other)
    {
    
    }

    void onInit()
    {
        this._playerTexture = Cache.loadTexture("Assets/Entities/Player.png");
        this.sprite = Sprite.make(this._playerTexture);
        this.sprite.camera = Camera.instance;
        super.onInit();
    }

    void onUpdate(ref float gameTime)
    {
        this._actualSpeed = this._baseSpeed * gameTime;

        if(InputManager.isKeyDown(SDL_SCANCODE_W))
            this.sprite.position += Vector2f(0, -this._actualSpeed);
        if(InputManager.isKeyDown(SDL_SCANCODE_S))
            this.sprite.position += Vector2f(0, this._actualSpeed);
        if(InputManager.isKeyDown(SDL_SCANCODE_A))
            this.sprite.position += Vector2f(-this._actualSpeed, 0);
        if(InputManager.isKeyDown(SDL_SCANCODE_D))
            this.sprite.position += Vector2f(this._actualSpeed, 0);

        Camera.instance.centreOn(sprite);
    }

    bool onEvent(SDL_Event event, bool handled)
    {
        return false;
    }

    void onUninit()
    {
        super.onUninit();
    }


private:
    Texture _playerTexture;
    float _baseSpeed = 150.0f;
    float _actualSpeed;
}

