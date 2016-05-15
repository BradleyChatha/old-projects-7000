import tk.MainGame;

import Common;

void main()
{
    // If we're running in the unittest mode, fix the CWD so it points to the "bin" folder.
    version(unittest)
    {
        fixCWD();
    }

    loadSDL();

    Allocators.setup();
    theAllocator = Allocators.Default;
    scope(exit) Allocators.printStats();
    scope(exit) writeln("Press enter to continue...");
    scope(exit) readln();

    Window.create("TK",  Rectangle(SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 860, 720), FPS(60));
    scope(exit) Window.destroy(); // It pretty much guarentees to run.
    
    auto game = Allocators.GameState.make!MainGame();
    
    Window.startGameLoop(game);
}

version(unittest)
{
    void fixCWD()
    {
        import std.path   : exists, getcwd, chdir;
        import std.string : endsWith;

        // Make sure we're in the "bin" folder.
        if(!getcwd().endsWith("bin"))
        {
            if(!exists("bin"))
            {
                writeln("Please run the tests in either the project's root directory, or from the 'bin' folder.");
                return;
            }
            else
                chdir("bin");
        }
    }
}