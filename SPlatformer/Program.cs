using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using SFML.Graphics;
using SFML.Window;
using SFMLHelper;

namespace SPlatformer
{
    class Program
    {
        static void Main(string[] args)
        {
            RenderWindow Wnd = new RenderWindow(new VideoMode(1280, 720, 32), "SPlatformer");
            Wnd.Closed += (object sender, EventArgs e) => { Wnd.Close(); };
            FPSCounter.Init();
            Controller.InDepthExceptions = true;

            Player Plr = new Player();
            Level Lvl = new Level("Map.txt", Plr);
                    
            while(Wnd.IsOpen)
            {
                Wnd.DispatchEvents();
                Lvl.Update(FPSCounter.DeltaTimeS, Plr);
                Plr.Update(FPSCounter.DeltaTimeS, Lvl);

                Wnd.Clear(Color.Magenta);
                                
                Lvl.Draw(Wnd);
                Plr.Draw(Wnd);

                Wnd.Display();
                FPSCounter.Update();
            }
        }
    }
}
