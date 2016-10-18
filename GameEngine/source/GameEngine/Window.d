module GameEngine.Window;

private
{
    import  GameEngine.Core;

    import  gfm.logger,
            gfm.sdl2;
}

class Window
{
    this(Core* c)
    {
        this.core = c;
    }

private:
    Core* core;
}