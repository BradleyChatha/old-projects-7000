using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using SFML.Window;
using SFML.Graphics;

namespace Pong
{
    class Program
    {
        static void Main(string[] args)
        {
            RenderWindow Wnd = new RenderWindow(new VideoMode(800, 600, 32), "Pong");

            Wnd.Closed += (object sender, EventArgs e) => { Wnd.Close(); };
            Wnd.SetFramerateLimit(60);

            Ball.Init();
            Message.Init();

            PlayerManager Player = new PlayerManager();
            AIManager AIPaddle = new AIManager();

            while (Wnd.IsOpen)
            {
                Wnd.DispatchEvents();

                if (!Ball.HasThereBeenWin)
                {
                    Player.Update();
                    AIPaddle.Update();
                    Ball.Update(Player.Paddle, AIPaddle.Paddle);
                }

                Wnd.Clear(Color.Magenta);

                Ball.Draw(Wnd);
                Player.Draw(Wnd);
                AIPaddle.Draw(Wnd);

                if (Ball.HasThereBeenWin)
                    Message.Draw(Wnd);

                Wnd.Display();
            }
        }
    }
}
