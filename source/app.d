import tk.MainGame;

import Common;

void main()
{
    loadSDL();

    Allocators.setup();
    theAllocator = Allocators.Default;
    scope(exit) Allocators.printStats();

    Window.create("TK",  Rectangle(SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 860, 720), FPS(60));
    scope(exit) Window.destroy(); // It pretty much guarentees to run.
    
    auto game = Allocators.GameState.make!MainGame();
    
    Window.startGameLoop(game);
}