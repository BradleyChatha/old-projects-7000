import jengine.core, jengine.graphics, sfml;

enum WINDOW_TITLE = "Animation Test";
enum WINDOW_SIZE  = Vector2u(860, 720);
enum ANIMATION    = "assets/animation.png";
enum TIME         = 1.5f;

final class Game : App, IPostBox
{
    mixin(IPostBox.generateOnMail!Game);

    private
    {
        Cache       _cache;
        Animation   _ani;
    }

    public
    {
        override void onInit(Engine engine)
        {
            super.onInit(engine);
            this._cache = new Cache();

            this._cache.cache(ANIMATION, Texture.fromFile(ANIMATION));
            this._ani = this._cache.cache("Sprite", Animation.create(this._cache.get!Texture(ANIMATION),
                                                                     Animation.FrameInfo(Vector2u(32, 32)),
                                                                     TIME));

            // Quick test to make sure Sprite.bounds uses Sprite.textureRect correctly
            // E.G the texture is something like 160x90, but the bounds' size should be 32x32, same as the texture rect.
            assert(this._ani.bounds.size == Vector2f(32, 32));

            super.engine.window.input.subscribe(this);
            this.tests();
        }

        override void onUninit()
        {
            this._cache.onUninit();
            this._cache = null;
            this._ani   = null;

            super.engine.window.input.unsubscribe(this);
            super.onUninit();
        }

        override void onUpdate(double delta)
        {
            this._ani.onUpdate(delta);

            super.engine.window.renderer.render(this._ani);
        }

        @MailBox(sfEvtClosed)
        void onClose(PostOffice, Mail)
        {
            super.engine.window.close();
        }

        @MailBox(sfEvtKeyPressed)
        void onKeyPress(PostOffice, ValueMail!sfEvent event)
        {
            sfEvent data = event.value;
            switch(data.key.code)
            {
                case sfKeyEscape:
                    super.engine.window.close();
                    break;

                case sfKeyUp:
                    auto nextRow = this._ani.currentRow;
                    if(nextRow == 0)
                        nextRow = this._ani.rowCount - 1;
                    else
                        nextRow -= 1;

                    this._ani.currentRow = nextRow;
                    break;

                case sfKeyDown:
                    auto nextRow = this._ani.currentRow + 1;
                    if(nextRow >= this._ani.rowCount)
                        nextRow = 0;

                    this._ani.currentRow = nextRow;
                    break;

                default: break;
            }
        }
    }

    // Just testing some stuff regarding the animation.
    private void tests()
    {
        import std.exception;
        auto tex = this._cache.get!Texture(ANIMATION);

        // Some strange notes:
        //  The scope(failure) guard in Animation.create doesn't seem to actually trigger the deconstructor with the
        //  call to theAllocator.dispose, but instead of seems to end up calling Animation.sprite...? External bug is my only guess.

        // Exception if FrameSize is 0 for either X or Y.
        assertThrown!GraphicsException(Animation.create(tex, Animation.FrameInfo(Vector2u(0, 1))));
        assertThrown!GraphicsException(Animation.create(tex, Animation.FrameInfo(Vector2u(1, 0))));

        // Exception if FrameArea is not evenly divisible by FrameSize
        assertThrown!GraphicsException(Animation.create(tex, Animation.FrameInfo(Vector2u(2, 2), IntRect(0, 0, 9, 8))));
        assertThrown!GraphicsException(Animation.create(tex, Animation.FrameInfo(Vector2u(2, 2), IntRect(0, 0, 8, 9))));
        assertThrown!GraphicsException(Animation.create(tex, Animation.FrameInfo(Vector2u(2, 2), IntRect(0, 0, 9, 9))));

        // Exception if Texture is null
        assertThrown!GraphicsException(Animation.create(null, Animation.FrameInfo(Vector2u(1, 1))));
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
    engine.doLoop(Yes.vsync);
}
