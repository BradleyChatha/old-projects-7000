using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using SFML.Graphics;
using SFML.Window;
using SFML.System;
using SFMLHelper;

namespace Asteroids
{
    class Program
    {
        static void Main(string[] args)
        {
            RenderWindow Wnd = new RenderWindow(new VideoMode(1280, 720, 32), "Asteroids");
            Wnd.SetFramerateLimit(60);
            Wnd.Closed += (object sender, EventArgs e)  => { Wnd.Close(); };

            Player Plr = new Player();
            AsteroidManager.Init();

            Font EndGameFont = new Font("Assets\\LiberationMono-Regular.ttf");

            Text EndGameText = new Text("Game Over", EndGameFont)
            {
                Color = Color.Red,
                Position = new Vector2f(100, 100),
                CharacterSize = 72
            };

            Console.WriteLine("---- Controls ----");
            Console.WriteLine("A - Rotate Left");
            Console.WriteLine("D - Rotate Right");
            Console.WriteLine("Space - Fire guns");
            Console.WriteLine("-------------------");

            while(Wnd.IsOpen)
            {
                Wnd.DispatchEvents();

                Wnd.Clear(Color.Black);

                if (Plr.IsPlayerAlive)
                {
                    AsteroidManager.Update(Plr);
                    Plr.Update();
                }
                else
                {
                    EndGameText.DisplayedString = $"Game Over, you scored {Plr.Score}";
                    Wnd.Draw(EndGameText);
                }  

                AsteroidManager.Draw(Wnd);
                Plr.Draw(Wnd);
                Wnd.Display();
            }
        }
    }
}
