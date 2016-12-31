using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using SFML.Graphics;
using SFML.System;
using SFML.Window;
using System.Runtime.InteropServices;

namespace Asteroids
{
    public class Player
    {
        public Player()
        {
            this.ShipTexture = new Texture("assets\\Ship.png");
            this.Ship = new Sprite(this.ShipTexture);
            this.Ship.Origin = new Vector2f(this.ShipTexture.Size.X / 2, this.ShipTexture.Size.Y / 2);
            this.Ship.Position = (new Vector2f((1280 / 2) - (this.ShipTexture.Size.X / 2), (720 / 2) - (this.ShipTexture.Size.Y / 2)) + this.Ship.Origin);

            this.Bullets = new List<Projectile>();

            this.RotationSpeed = 4;
            this.HasAlreadyFired = false;

            this.ScoreFont = new Font("assets\\LiberationMono-Regular.ttf");
            this.ScoreText = new Text("", this.ScoreFont)
            {
                Position = new Vector2f(30, 30),
                Color = Color.White,
                CharacterSize = 32
            };
        }

        public void Update()
        {
            if(Keyboard.IsKeyPressed(Keyboard.Key.A))
            {
                this.Ship.Rotation -= this.RotationSpeed;
            }

            if (Keyboard.IsKeyPressed(Keyboard.Key.D))
            {
                this.Ship.Rotation += this.RotationSpeed;
            }

            if (Keyboard.IsKeyPressed(Keyboard.Key.Space) && !this.HasAlreadyFired)
            {
                this.SpawnBullet();
                this.HasAlreadyFired = true;
            }
            else if(!Keyboard.IsKeyPressed(Keyboard.Key.Space) && this.HasAlreadyFired)
            {
                this.HasAlreadyFired = false;
            }


            for (int i = 0; i < this.Bullets.Count; i++)
            {
                if (this.Bullets[i] == null)
                    continue;

                if (!this.Bullets[i].IsAlive)
                {
                    this.Bullets[i] = null;
                    continue;
                }

                this.Bullets[i].Update();
            }

            this.ScoreText.DisplayedString = this.Score.ToString();
        }

        public void Draw(RenderWindow Wnd)
        {
            Wnd.Draw(this.Ship);

            for (int i = 0; i < this.Bullets.Count; i++)
            {
                if (this.Bullets[i] == null)
                    continue;

                this.Bullets[i].Draw(Wnd);
            }

            Wnd.Draw(this.ScoreText);
        }

        private Vector2f GetTip()
        {
            Vector2f Position = new Vector2f();

            Position = new Vector2f(((this.Ship.Position.X - this.Ship.Origin.X) + (this.ShipTexture.Size.X / 2)) - 4, ((this.Ship.Position.Y - (this.Ship.Origin.Y * 2)) + (this.ShipTexture.Size.Y / 2)) - Projectile.Size.Y);

            return Position;
        }

        private void SpawnBullet()
        {
            Transform Trans = Transform.Identity;
            Trans.Rotate(this.Ship.Rotation, this.Ship.Position);

            Vector2f Point = Trans.TransformPoint(this.GetTip());


            for(int i = 0; i < this.Bullets.Count; i++)
            {
                if(this.Bullets[i] == null)
                {
                    this.Bullets[i] = new Projectile(Point, this.Ship.Rotation);
                    return;
                }
            }

            this.Bullets.Add(new Projectile(Point, this.Ship.Rotation));
        }

        public void AddPoints()
        {
            this.Score += 10;
        }

        public List<Projectile> Bullets
        {
            get;
            private set;
        }

        private float RotationSpeed;
        private Sprite Ship;
        private Texture ShipTexture;
        private bool HasAlreadyFired;
        private Font ScoreFont;
        private Text ScoreText;
        private int Score;
    }
}
