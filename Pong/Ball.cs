using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using SFML.Graphics;
using SFML.Window;
using SFML.System;

namespace Pong
{
    static class Ball
    {
        public static void Init()
        {
            BallShape = new CircleShape(15)
            {
                FillColor = Color.Cyan,
                OutlineColor = Color.Black,
                OutlineThickness = 5,
                Position = new Vector2f(400, 100)
            };

            Random R = new Random();
            DirectionChooser = new Random();

            ///Right
            if (R.Next(2) == 1)
                Direction = Speed;
            ///Left
            else
                Direction = -Speed;

            Angle = 10; // DirectionChooser.Next(90);
            HasThereBeenWin = false;
        }
        
        static public void Update(Paddle Right, Paddle Left)
        {
            if (!HasThereBeenWin)
            {
                if (Right.CheckCollisionWithBall() || Left.CheckCollisionWithBall() || CheckOnBottom() || CheckOnTop())
                {
                    Direction = -Direction;
                    Angle = DirectionChooser.Next(-1, 1);
                }

                if (Angle >= 0)
                    BallShape.Position = new Vector2f(BallShape.Position.X + Direction, BallShape.Position.Y - 2);
                else
                    BallShape.Position = new Vector2f(BallShape.Position.X + Direction, BallShape.Position.Y + 2);

               

                ///Win Conditions
                ///AI Wins
                if (BallShape.Position.X <= 0)
                {
                    Message.SetMessage("The AI has won!");
                    HasThereBeenWin = true;
                }
                else if (BallShape.Position.X >= 800)
                {
                    Message.SetMessage("The player has won!");
                    HasThereBeenWin = true;
                }
            }
        }

        static public void Draw(RenderWindow Wnd)
        {
            Wnd.Draw(BallShape);
        }

        public static bool CheckOnBottom()
        {
            return (BallShape.Position.Y - (BallShape.Radius * 2) >= 800);
        }

        public static bool CheckOnTop()
        {
            return (BallShape.Position.Y <= 0);
        }

        public static Vector2f Position
        {
            get { return BallShape.Position; }
        }

        public static bool HasThereBeenWin
        {
            get;
            private set;
        }

        public static float Radius
        {
            get { return BallShape.Radius; }
        }

        public static IntRect Box
        {
            get { return new IntRect((Vector2i)BallShape.Position, new Vector2i((int)BallShape.Radius * 2, (int)BallShape.Radius * 2)); }
        }

        private static float Direction;
        private static readonly float Speed = 15.0f;
        private static Random DirectionChooser;
        private static float Angle;
        private static CircleShape BallShape;
    }
}
