using SFML.Graphics;
using SFML.Window;
using SFML.System;
using SFMLHelper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SPlatformer
{
    public enum Direction
    {
        Up = 0,
        Down,
        Left,
        Right
    }

    public class Player
    {
        public Player()
        {
            this.JumpForce = (this.Gravity * 1.5f);
            this.MovementSpeed = 400.0f;

            this.PlayerTexture = new Texture("Assets\\Player.png");
            this.PlayerSprite = new Sprite(this.PlayerTexture);
            this.PlayerSprite.Position = new Vector2f(32, 15);

            this.IsCollisionDetected = new Dictionary<Direction, bool>();

            this.IsCollisionDetected[Direction.Up] = false;
            this.IsCollisionDetected[Direction.Down] = false;
            this.IsCollisionDetected[Direction.Left] = false;
            this.IsCollisionDetected[Direction.Right] = false;
        }

        public void Update(float dt, Level Lvl)
        {
            this.UpdateDownCollision(Lvl);
            this.UpdateUpCollision(Lvl);
            this.UpdateRightCollision(Lvl);
            this.EnactGravity(dt);

            if (this.PlayerSprite.Position.Y > 720)
                this.PlayerSprite.Position = new Vector2f(this.PlayerSprite.Position.X, -this.PlayerTexture.Size.Y);

            if(Keyboard.IsKeyPressed(Keyboard.Key.D) && !this.IsCollisionDetected[Direction.Right])
                this.PlayerSprite.Position = new Vector2f(this.PlayerSprite.Position.X + (this.MovementSpeed * dt), this.PlayerSprite.Position.Y);
            if (Keyboard.IsKeyPressed(Keyboard.Key.A))
                this.PlayerSprite.Position = new Vector2f(this.PlayerSprite.Position.X - (this.MovementSpeed * dt), this.PlayerSprite.Position.Y);
        }

        public void Draw(RenderWindow Wnd)
        {
            Wnd.Draw(this.PlayerSprite);
        }

        public FloatRect Rect
        {
            get
            {
                return new FloatRect(this.PlayerSprite.Position.X, this.PlayerSprite.Position.Y, this.PlayerTexture.Size.X, this.PlayerTexture.Size.Y);
            }
        }

        public Vector2u Size
        {
            get { return this.PlayerTexture.Size; }
        }

        public Vector2f Position
        {
            get { return this.PlayerSprite.Position; }
        }

        public Vector2i Cell
        {
            get { return new Vector2i((int)Math.Floor(this.PlayerSprite.Position.X / this.PlayerTexture.Size.X), (int)Math.Floor(this.PlayerSprite.Position.Y / this.PlayerTexture.Size.Y)); }
        }

        private void EnactGravity(float dt)
        {
            if (!this.IsCollisionDetected[Direction.Down])
            {
                ///First Gravity goes down so we need a constant down direction, use a normalised unit vector.
                Vector2f Down = Vector.Normalise(new Vector2f(0, 1));

                ///Now we want to calculate acceleration.
                float YPosition = (float)(Math.Cos((double)Down.Y) * this.Gravity) * dt;
                this.PlayerSprite.Position = new Vector2f(this.PlayerSprite.Position.X, this.PlayerSprite.Position.Y + YPosition);
            }
        }

        private void UpdateDownCollision(Level Lvl)
        {
            ///Top of tile, bottom of player
            FloatRect BottomOfPlayer = new FloatRect(new Vector2f(this.PlayerSprite.Position.X, this.PlayerSprite.Position.Y + this.PlayerTexture.Size.Y), new Vector2f(this.PlayerTexture.Size.X, 2));
            Tile T = Lvl.GetTileByCell(new Vector2i(this.Cell.X, this.Cell.Y + 1));

            if (T == null)
            {                
                this.IsCollisionDetected[Direction.Down] = false;
                goto CollisionBottomCheckRightSide;
            }

            if (BottomOfPlayer.Intersects(T.Rect))
                this.IsCollisionDetected[Direction.Down] = true;

            CollisionBottomCheckRightSide:

            T = Lvl.GetTileByCell(new Vector2i(this.Cell.X + 1, this.Cell.Y + 1));

            if (T == null)
            {
                return;
            }

            if (BottomOfPlayer.Intersects(T.Rect))
                this.IsCollisionDetected[Direction.Down] = true;
        }

        private void UpdateUpCollision(Level Lvl)
        {
            FloatRect TopOfPlayer = new FloatRect(new Vector2f(this.PlayerSprite.Position.X, this.PlayerSprite.Position.Y), new Vector2f(this.PlayerTexture.Size.X, 2));
            Tile T = Lvl.GetTileByCell(new Vector2i(this.Cell.X, this.Cell.Y - 1));

            if(T == null)
            {
                this.IsCollisionDetected[Direction.Up] = false;
                goto CollisionTopCheckRightSide;
            }

            if (TopOfPlayer.Intersects(T.Rect))
                this.IsCollisionDetected[Direction.Up] = true;

            CollisionTopCheckRightSide:
            T = Lvl.GetTileByCell(new Vector2i(this.Cell.X + 1, this.Cell.Y - 1));

            if (T == null)
                return;

            if (TopOfPlayer.Intersects(T.Rect))
                this.IsCollisionDetected[Direction.Up] = true;
        }

        private void UpdateRightCollision(Level Lvl)
        {
            FloatRect RightOfPlayer = new FloatRect(new Vector2f(this.PlayerSprite.Position.X + this.PlayerTexture.Size.X, this.PlayerSprite.Position.Y), new Vector2f(2, this.PlayerTexture.Size.Y));
            Tile T = Lvl.GetTileByCell(new Vector2i(this.Cell.X + 1, this.Cell.Y));

            if (T == null)
            {
                this.IsCollisionDetected[Direction.Right] = false;
                goto ColliisionRightCheckBottom;
            }

            if (RightOfPlayer.Intersects(T.Rect))
                this.IsCollisionDetected[Direction.Right] = true;

            ColliisionRightCheckBottom:

            T = Lvl.GetTileByCell(new Vector2i(this.Cell.X + 1, this.Cell.Y + 1));
                        
            if (T == null)
                return;

            if (RightOfPlayer.Intersects(T.Rect))
                this.IsCollisionDetected[Direction.Right] = true;
        }

        private Dictionary<Direction, bool> IsCollisionDetected;
        private float Gravity = 300f;
        private float MovementSpeed;
        private float JumpForce;
        private Texture PlayerTexture;
        private Sprite PlayerSprite;
    }
}
