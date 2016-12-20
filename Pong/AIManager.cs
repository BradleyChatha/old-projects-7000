using SFML.Graphics;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Pong
{
    public class AIManager
    {
        public AIManager()
        {
            this.Pad = new Paddle(ScreenSide.Right);
        }

        public void Update()
        {
            if(Ball.Position.Y > this.Pad.Position.Y && !this.Paddle.CheckOnBottom())
            {
                this.Pad.Move(7);
            }
            else if(Ball.Position.Y < this.Pad.Position.Y && !this.Paddle.CheckOnTop())
            {
                this.Pad.Move(-7);
            }
        }

        public void Draw(RenderWindow Wnd)
        {
            this.Pad.Draw(Wnd);
        }

        public Paddle Paddle
        {
            get { return this.Pad; }
        }
      
        private Paddle Pad;
    }
}
