using SFML.Graphics;
using SFML.Window;
using SFML.System;
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
            this.JumpForce = (9.8f * 1.5f);
            this.MovementSpeed = 50.0f;

            this.PlayerTexture = new Texture("Assets\\Player.png");
            this.PlayerSprite = new Sprite(this.PlayerTexture);
        }

        public void Update(float dt)
        {            
            if(Keyboard.IsKeyPressed(Keyboard.Key.D))
                this.PlayerSprite.Position = new Vector2f(this.PlayerSprite.Position.X + (this.MovementSpeed * dt), this.PlayerSprite.Position.Y);
            if (Keyboard.IsKeyPressed(Keyboard.Key.A))
                this.PlayerSprite.Position = new Vector2f(this.PlayerSprite.Position.X - (this.MovementSpeed * dt), this.PlayerSprite.Position.Y);
        }

        public void Draw(RenderWindow Wnd)
        {
            Wnd.Draw(this.PlayerSprite);
        }

        private float MovementSpeed;
        private float JumpForce;
        private Texture PlayerTexture;
        private Sprite PlayerSprite;
    }
}
