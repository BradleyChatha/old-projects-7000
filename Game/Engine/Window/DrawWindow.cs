using System;
using System.Collections.Generic;
using SFML.Window;
using SFML.System;
using SFML.Graphics;
using System.Text;

namespace Game.Engine
{
    public class DrawWindow
    {
        public DrawWindow(Vector2u WindowSize, string Title)
        {
            this.WindowHandle = new RenderWindow(new VideoMode(WindowSize.X, WindowSize.Y, 32), Title);
            this.WindowHandle.Closed += (s, e) => {this.WindowHandle.Close(); Logger.Log(LogLevel.Info, "Destroyed the DrawWindow"); };
            this.DrawStack = new List<Drawable>();
            this.Rng = new Random();

            this.World = new Map("Map.XML");
            this.World.LoadMap(this);

            FPSCounter.Init();

            Logger.Log(LogLevel.Info, "Created a new DrawWindow");
        }

        public void Loop()
        {
            while(this.WindowHandle.IsOpen)
            {
                this.WindowHandle.DispatchEvents();

                this.World.Update();

                for (int i = 0; i < this.DrawStack.Count; i++)
                {
                    if(this.DrawStack[i].DoesUpdate)
                        this.DrawStack[i].Update();
                }

                this.WindowHandle.Clear(Color.Black);

                this.World.Draw(this);

                for(int i = 0; i < this.DrawStack.Count; i++)
                    this.DrawStack[i].Draw(this);
                    //this.WindowHandle.Draw(this.DrawStack[i].DrawableSprite);

                this.WindowHandle.Display();
                FPSCounter.Update();
            }
        }

        public void AddDrawable(Drawable Draw, string Name = "")
        {
            this.DrawStack.Add(Draw);
        }

        public RenderWindow WindowHandle;
        private List<Drawable> DrawStack;
        private Map World;
        private Random Rng;
    }
}
