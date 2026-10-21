using System;
using System.Diagnostics;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using SFML.Graphics;
using SFML.Window;

namespace Bullet_Hell
{
    class Program
    {
        static void Main(string[] args)
        {
            RenderWindow Window = new RenderWindow(new VideoMode(600, 1000, 32), "Bullet Hell", Styles.Close | Styles.Titlebar);
            Window.Closed += (s, e) => Window.Close();
            Stopwatch Delta = Stopwatch.StartNew();

            Entities.Entity TestEntity = new Entities.Entity("Text.xml");

            while(Window.IsOpen)
            {
                Window.DispatchEvents();

                float Dt = Delta.ElapsedTicks;
                Delta.Restart();

                Window.Clear(Color.Black);

                Window.Display();
            }
        }
    }
}
