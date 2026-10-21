module tk.Test;

version(unittest)
{
    /++
     + Makes sure that we're in the "bin" folder.
     + ++/
    void fixCWD()
    {
        import std.path   : exists, getcwd, chdir;
        import std.string : endsWith;
        
        // Make sure we're in the "bin" folder.
        if(!getcwd().endsWith("bin"))
        {
            if(!exists("bin"))
            {
                import std.stdio;
                writeln("Please run the tests in either the project's root directory, or from the 'bin' folder.");
                return;
            }
            else
                chdir("bin");
        }
    }

    private static bool _setup = false;
    /++
     + Sets up everything needed to test.
     + ++/
    void setupTestEnv(string testName)
    {
        import std.stdio;
        writefln("[Test %s] is currently running(probably).", testName);

        if(_setup)
            return;

        _setup = true;

        import jengine.core.allocators;
        Allocators.setup();

        fixCWD();

        import jengine.core.sdl;
        loadSDL();

        import jengine.graphics.window;
        Window.create("Unittests", Rectangle(SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 860, 720), FPS(60));

        import tk.World.Tiles.Tile;
        loadTiles();
    }

    import tk.Entities.Player;
    /++
     + Creates a player for testing use.
     + ++/
    Player makePlayer()
    {
        auto p = new Player();
        p.onInit();

        return p;
    }
}