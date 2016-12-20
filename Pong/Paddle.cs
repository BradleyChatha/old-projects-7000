using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using SFML.Graphics;
using SFML.System;

namespace Pong
{
    public enum ScreenSide
    {
        Left = 0,
        Right
    }

    public class Paddle
    {
        public Paddle(ScreenSide Side)
        {
            Random ColorGenerator = new Random();
            this.Side = Side;

            this.PaddleShape = new RectangleShape()
            {
                FillColor = new Color((byte)ColorGenerator.Next(0, 255), (byte)ColorGenerator.Next(0, 255), (byte)ColorGenerator.Next(0, 255)),
                OutlineColor = Color.Black,
                OutlineThickness = 5.0f,
                Size = new Vector2f(30, 75)
            };

            if (Side == ScreenSide.Left)
                this.PaddleShape.Position = new Vector2f(this.PaddleShape.Position.X + 5, this.PaddleShape.Position.Y + 5);
            else
            {
                Vector2f Position = new Vector2f()
                {
                    X = (800 - (this.PaddleShape.Size.X + this.PaddleShape.OutlineThickness)),
                    Y = this.PaddleShape.OutlineThickness
                };

                this.PaddleShape.Position = Position;
            }
        }

        public void Draw(RenderWindow Wnd)
        {
            Wnd.Draw(this.PaddleShape);
        }
        
        public void Move(float Offset)
        {
            this.PaddleShape.Position += new Vector2f(0, Offset);
        }

        public bool CheckOnBottom()
        {
            return (this.PaddleShape.Position.Y + this.PaddleShape.Size.Y + 5 >= 600);
        }

        public bool CheckOnTop()
        {
            return (this.PaddleShape.Position.Y - 5 <= 0);
        }

        public bool CheckCollisionWithBall()
        {
            IntRect Box = new IntRect((Vector2i)this.PaddleShape.Position, (Vector2i)this.PaddleShape.Size);

            return Box.Intersects(Ball.Box);
        }

        public Vector2f Position
        {
            get { return this.PaddleShape.Position; }
        } 

        public Vector2f Size
        {
            get { return this.PaddleShape.Size; }
        }

        private ScreenSide Side;
        private RectangleShape PaddleShape;
    }
}
