import std.stdio;
import jengine.core, jengine.graphics, sfml;

enum WINDOW_SIZE  = Vector2u(560, 320);
enum WINDOW_TITLE = "Pong";
enum PADDLE_FILE  = "assets/paddle.png";
enum PADDLE_SPEED = 200.0f; // pixel/s
enum BALL_FILE    = "assets/tahn.png";
enum BALL_SPEED   = 300.0f;
enum SCORE_STRING = "Score: Player(%s) | AI(%s)";

class Game : App, IPostBox
{
    mixin(IPostBox.generateOnMail!Game);

    private
    {
        Cache  _cache;
        Sprite _playerPaddle;
        Sprite _aiPaddle;
        Sprite _ball;
        bool   _ballMoveLeft, _ballMoveDown;
        bool   _playerMoveUp, _playerMoveDown;
        uint   _playerScore,  _aiScore;
        Text   _scoreText;
    }

    public
    {
        override void onInit(Engine engine)
        {
            super.onInit(engine);

            this._cache = new Cache();
            this._cache.cache(PADDLE_FILE, Texture.fromFile(PADDLE_FILE));
            this._cache.cache(BALL_FILE,   Texture.fromFile(BALL_FILE));

            this._playerPaddle = this._cache.cache("Player", Sprite.create(this._cache.get!Texture(PADDLE_FILE), Vector2f(0, 0)));
            this._aiPaddle     = this._cache.cache("AI",     Sprite.create(this._cache.get!Texture(PADDLE_FILE), Vector2f(0, 0)));                    
            this._ball         = this._cache.cache("Ball",   Sprite.create(this._cache.get!Texture(BALL_FILE),   Vector2f(0, 0)));
            this._scoreText    = this._cache.cache("Score",  Text.create!char(Font.debugFont, ""));

            this.resetPositions();
            engine.window.input.subscribe(this);
        }

        override void onUninit()
        {
            this._cache.onUninit();
            this._cache         = null;
            this._playerPaddle  = null;
            this._aiPaddle      = null;
            this._ball          = null;

            engine.window.input.unsubscribe(this);
            super.onUninit();
        }

        void resetPositions()
        {
            auto screen     = engine.window.size;
            auto paddleSize = this._cache.get!Texture(PADDLE_FILE).size;
            auto ballSize   = this._cache.get!Texture(BALL_FILE).size;
            this._playerPaddle.position = Vector2f(0, 0);
            this._aiPaddle.position     = Vector2f(screen.x - paddleSize.x, 0);
            this._ball.position         = Vector2f((screen.x / 2) - (ballSize.x / 2),
                                                   (screen.y / 2) - (ballSize.y / 2));

            // Always start with it going towards the AI
            this._ballMoveLeft = false;
            this.updateScore();
        }

        void updateScore()
        {
            import std.format;
            this._scoreText.text = format(SCORE_STRING, this._playerScore, this._aiScore);
            auto size            = this._scoreText.size;
            auto screen          = super.engine.window.size;

            this._scoreText.position = Vector2f((screen.x / 2) - (size.x / 2), 0);
        }
        
        override void onUpdate(double delta)
        {
            auto screen  = super.engine.window.size;
            auto p_speed = (PADDLE_SPEED * delta);
            auto b_speed = (BALL_SPEED * delta);

            /+ Player Logic +/
            if(this._playerMoveUp)
                this._playerPaddle.move(Vector2f(0, -p_speed));
            if(this._playerMoveDown)
                this._playerPaddle.move(Vector2f(0, p_speed));

            auto playerPos = this._playerPaddle.position;
            auto maxY      = screen.y - this._playerPaddle.texture.size.y;
            if(playerPos.y < 0)
                this._playerPaddle.move(Vector2f(0, -playerPos.y));
            if(playerPos.y > maxY)
                this._playerPaddle.move(Vector2f(0, maxY - playerPos.y));

            /+ Ball logic +/
            if(this._ballMoveDown)
                this._ball.move(Vector2f(0, b_speed));
            else
                this._ball.move(Vector2f(0, -b_speed));

            if(this._ballMoveLeft)
                this._ball.move(Vector2f(-b_speed, 0));
            else
                this._ball.move(Vector2f(b_speed, 0));

            auto bpos  = this._ball.position;
            auto bsize = this._ball.texture.size;
            if(bpos.y < 0)
                this._ballMoveDown = true;
            else if(bpos.y + bsize.y > screen.y)
                this._ballMoveDown = false;
            if(bpos.x < 0)
            {
                this._aiScore += 1;
                this.resetPositions();
            }
            else if(bpos.x + bsize.x > screen.x)
            {
                this._playerScore += 1;
                this.resetPositions();
            }

            /+ AI Logic(This is next-gen stuff right here) +/
            auto aiPos = this._aiPaddle.position;
            if(bpos.y > aiPos.y + this._playerPaddle.texture.size.y / 2)
                this._aiPaddle.move(Vector2f(0, p_speed));
            else
                this._aiPaddle.move(Vector2f(0, -p_speed));

            /+ Ball collision logic +/
            // It should be noted, that I'm only using raw-sfml stuff because Jengine currently doesn't have this stuff.
            // It really should get it soon though.
            auto psize  = this._playerPaddle.texture.size;
            auto prect  = FloatRect(playerPos.x, playerPos.y, psize.x, psize.y).asSfml;
            auto airect = FloatRect(aiPos.x,     aiPos.y,     psize.x, psize.y).asSfml;
            auto brect  = FloatRect(bpos.x,      bpos.y,      bsize.x, bsize.y).asSfml;

            if(sfFloatRect_intersects(&prect, &brect, null))
                this._ballMoveLeft = false;
            if(sfFloatRect_intersects(&airect, &brect, null))
                this._ballMoveLeft = true;

            // Render everything.
            auto renderer = super.engine.window.renderer;
            renderer.render(this._scoreText);
            renderer.render(this._playerPaddle);
            renderer.render(this._aiPaddle);
            renderer.render(this._ball);
        }

        @MailBox(sfEvtClosed)
        void onClosed(PostOffice, Mail)
        {
            super.engine.window.close();
        }

        @MailBox(sfEvtKeyPressed)
        void onKeyPress(PostOffice, ValueMail!sfEvent event)
        {
            auto key = event.value.key.code;
            switch(key)
            {
                case sfKeyW:
                case sfKeyUp:
                    this._playerMoveUp = true;
                    break;
                    
                case sfKeyS:
                case sfKeyDown:
                    this._playerMoveDown = true;
                    break;
                    
                default: break;
            }
        }

        @MailBox(sfEvtKeyReleased)
        void onKeyRelease(PostOffice, ValueMail!sfEvent event)
        {
            auto key = event.value.key.code;
            switch(key)
            {
                case sfKeyW:
                case sfKeyUp:
                    this._playerMoveUp = false;
                    break;
                    
                case sfKeyS:
                case sfKeyDown:
                    this._playerMoveDown = false;
                    break;
                    
                default: break;
            }
        }
    }
}

void main(string[] args)
{
    loadSFML();

    auto app    = new Game();
    auto window = new Window(WINDOW_TITLE, WINDOW_SIZE);
    auto engine = new Engine();
    engine.onInit(args, app, window);
    scope(exit)
    {
        engine.onUninit();
        assert(!app.hasInit);
    }

    import std.typecons : Yes, No;
    engine.doLoop(No.vsync, 500);
}
