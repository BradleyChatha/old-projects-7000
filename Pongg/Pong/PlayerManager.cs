using SFML.Window;
using SFML.Graphics;

namespace Pong
{
    class PlayerManager
    {
        public PlayerManager()
        {
            Pad = new Paddle(ScreenSide.Left);
        }

        public void Update()
        {
            if (Keyboard.IsKeyPressed(Keyboard.Key.W) && !this.Pad.CheckOnTop())
            {
                this.Pad.Move(-7);

            }
            else if (Keyboard.IsKeyPressed(Keyboard.Key.S) && !this.Pad.CheckOnBottom())
            {
                this.Pad.Move(7);
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
