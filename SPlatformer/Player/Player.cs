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

            this.ResetCollision();
        }

        public void Update(float dt, Level Lvl)
        {
            this.UpdateCollision(Lvl);
            this.EnactGravity(dt);

            if (this.PlayerSprite.Position.Y > 720)
                this.PlayerSprite.Position = new Vector2f(this.PlayerSprite.Position.X, -this.PlayerTexture.Size.Y);

            if(Keyboard.IsKeyPressed(Keyboard.Key.D) && !this.IsCollisionDetected[Direction.Right])
                this.PlayerSprite.Position = new Vector2f(this.PlayerSprite.Position.X + (this.MovementSpeed * dt), this.PlayerSprite.Position.Y);
            if (Keyboard.IsKeyPressed(Keyboard.Key.A) && !this.IsCollisionDetected[Direction.Left])
                this.PlayerSprite.Position = new Vector2f(this.PlayerSprite.Position.X - (this.MovementSpeed * dt), this.PlayerSprite.Position.Y);
        }

        public void SetPosition(Vector2f Position)
        {
            this.PlayerSprite.Position = Position;
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

        public bool IsCollidingWith(Tile T)
        {
            if (this.LastTileToBeCollidedWith == T)
                return true;
            else
                return false;
        }

        private void ResetCollision()
        {
            this.IsCollisionDetected[Direction.Up] = false;
            this.IsCollisionDetected[Direction.Down] = false;
            this.IsCollisionDetected[Direction.Left] = false;
            this.IsCollisionDetected[Direction.Right] = false;
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

        private void UpdateCollision(Level Lvl)
        {
            this.ResetCollision();

            ///Down Collision
            this.CheckCollision(Lvl.GetTileByCell(new Vector2i(this.Cell.X, this.Cell.Y + 1)), Direction.Down);
            this.CheckCollision(Lvl.GetTileByCell(new Vector2i(this.Cell.X + 1, this.Cell.Y + 1)), Direction.Down);

            ///Up Collision
            this.CheckCollision(Lvl.GetTileByCell(new Vector2i(this.Cell.X, this.Cell.Y - 1)), Direction.Up);
            this.CheckCollision(Lvl.GetTileByCell(new Vector2i(this.Cell.X + 1, this.Cell.Y - 1)), Direction.Up);

            ///Right Collision
            this.CheckCollision(Lvl.GetTileByCell(new Vector2i(this.Cell.X + 1, this.Cell.Y)), Direction.Right);

            Vector2f OldPlayerPosition = this.PlayerSprite.Position;
            this.PlayerSprite.Position = new Vector2f(this.PlayerSprite.Position.X + 2, this.PlayerSprite.Position.Y);

            if (!this.IsCollisionDetected[Direction.Down])
                this.CheckCollision(Lvl.GetTileByCell(new Vector2i(this.Cell.X + 1, this.Cell.Y + 1)), Direction.Right);

            this.PlayerSprite.Position = OldPlayerPosition;

            ///Left Collision
            this.CheckCollision(Lvl.GetTileByCell(new Vector2i(this.Cell.X, this.Cell.Y)), Direction.Left);
            
            if (!this.IsCollisionDetected[Direction.Down])
                this.CheckCollision(Lvl.GetTileByCell(new Vector2i(this.Cell.X - 1, this.Cell.Y + 1)), Direction.Left);
        }

        private void CheckCollision(Tile T, Direction Dir)
        {
            if (T == null)
                return;
            else if (!T.CanCollide)
                return;


            FloatRect Rect = new FloatRect();

            switch(Dir)
            {
                case Direction.Down:
                    Rect = new FloatRect(new Vector2f(this.PlayerSprite.Position.X, this.PlayerSprite.Position.Y + this.PlayerTexture.Size.Y), new Vector2f(this.PlayerTexture.Size.X, 3));
                    break;

                case Direction.Up:
                    Rect = new FloatRect(new Vector2f(this.PlayerSprite.Position.X, this.PlayerSprite.Position.Y), new Vector2f(this.PlayerTexture.Size.X, 2));
                    break;

                case Direction.Right:
                    Rect = new FloatRect(new Vector2f(this.PlayerSprite.Position.X + this.PlayerTexture.Size.X, this.PlayerSprite.Position.Y), new Vector2f(-2, this.PlayerTexture.Size.Y));
                    break;

                case Direction.Left:
                    Rect = new FloatRect(new Vector2f(this.PlayerSprite.Position.X, this.PlayerSprite.Position.Y), new Vector2f(-2, this.PlayerTexture.Size.Y));
                    break;
            }

            if (Rect.Intersects(T.Rect))
            {
                this.IsCollisionDetected[Dir] = true;
                this.LastTileToBeCollidedWith = T;
            }
        }
        
        private Tile LastTileToBeCollidedWith;
        private Dictionary<Direction, bool> IsCollisionDetected;
        private float Gravity = 300f;
        private float MovementSpeed;
        private float JumpForce;
        private Texture PlayerTexture;
        private Sprite PlayerSprite;
    }
}
