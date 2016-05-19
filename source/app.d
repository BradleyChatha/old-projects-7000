import tk.MainGame;

import Common;
import tk.World.Map.Map;

void main()
{
    // If we're running in the unittest mode, return, since we don't care about do anything else.
    version(unittest)
    {
        return;
    }
    else
    {
        loadSDL();

        Allocators.setup();
        theAllocator = Allocators.Default;
        scope(exit) 
        {
            writeln("Press enter to continue...");
            readln();

            Allocators.printStats();
        }

        Window.create("TK",  Rectangle(SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 860, 720), FPS(60));
        scope(exit) Window.destroy(); // It pretty much guarentees to run.

        auto game = Allocators.GameState.make!MainGame();
        
        Window.startGameLoop(game);
    }
}