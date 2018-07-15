using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using SFML.System;
using Game.Engine;
using Game.Gameplay;

namespace Game
{
    class Program
    {
        static void Main(string[] args)
        {
            Logger.Init();
            DrawWindow Wnd = new DrawWindow(new Vector2u(1024, 720), "Test");
            Player Plr = new Player("Tahn.png", ref Wnd);
            Plr.Position = new Vector2f(10, 78);
            Button Btn = new Button("Tahn.png", new Vector2f(400, 400), () => Console.WriteLine("Clicked"), () => Console.WriteLine("Hover Entered"), () => Console.WriteLine("Hover left"), ref Wnd);

            Wnd.AddDrawable(Btn);
            Wnd.AddDrawable(Plr);
            Wnd.Loop();

            Logger.Deinit();
        }
    }
}
