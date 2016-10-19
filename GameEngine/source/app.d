import std.stdio;

import GameEngine.Core;
import GameEngine.Window;

void main(string[] Args)
{
    Core core = new Core();
    Window window = new Window("GLFWWindow", 800, 600);
    
    while(window.IsOpen())
    {
        window.Clear(Colour(1, 0, 0, 1));
        window.Draw();
    }
}