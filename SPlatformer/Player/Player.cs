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
    public class Player
    {
        public Player()
        {
            this.JumpForce = (this.Gravity * 1.5f);
            this.MovementSpeed = 400.0f;

            this.PlayerTexture = new Texture("Assets\\Player.png");
            this.PlayerSprite = new Sprite(this.PlayerTexture);
        }

        public void Update(float dt)
        {
            this.EnactGravity(dt);

            if (this.PlayerSprite.Position.Y > 720)
                this.PlayerSprite.Position = new Vector2f(this.PlayerSprite.Position.X, -this.PlayerTexture.Size.Y);

            if(Keyboard.IsKeyPressed(Keyboard.Key.D))
                this.PlayerSprite.Position = new Vector2f(this.PlayerSprite.Position.X + (this.MovementSpeed * dt), this.PlayerSprite.Position.Y);
            if (Keyboard.IsKeyPressed(Keyboard.Key.A))
                this.PlayerSprite.Position = new Vector2f(this.PlayerSprite.Position.X - (this.MovementSpeed * dt), this.PlayerSprite.Position.Y);
        }

        public void Draw(RenderWindow Wnd)
        {
            Wnd.Draw(this.PlayerSprite);
        }

        private void EnactGravity(float dt)
        {
            ///First Gravity goes down so we need a constant down direction, use a normalised unit vector.
            Vector2f Down = Vector.Normalise(new Vector2f(0, 1));
            
            ///Now we want to calculate acceleration.
            float YPosition = (float)(Math.Cos((double)Down.Y) * this.Gravity) * dt;

            this.PlayerSprite.Position = new Vector2f(this.PlayerSprite.Position.X, this.PlayerSprite.Position.Y + YPosition);
        }

        private void CheckCollisionBelow()
        {

        }

        private float Gravity = 300f;
        private float MovementSpeed;
        private float JumpForce;
        private Texture PlayerTexture;
        private Sprite PlayerSprite;
    }
}
