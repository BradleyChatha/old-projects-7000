using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using SFML.Graphics;
using SFML.System;
using SFMLHelper;

namespace Asteroids
{
    public class Asteroid
    {
        public Asteroid(Vector2f SpawnLocation)
        {
            this.AsteroidTexture = new Texture("Assets\\Asteroid.png");

            this.AsteroidSprite = new Sprite(this.AsteroidTexture)
            {
                Position = SpawnLocation
            };

            this.MovementSpeed = 2.8f;
            this.IsAlive = true;
            this.NeedsReset = false;
        }

        public void Draw(RenderWindow Wnd)
        {
            Wnd.Draw(this.AsteroidSprite);
        }

        public void Update(Player Plr)
        {
            #region Direction
            Vector2f AsteroidDirection = new Vector2f(0, 0);

            AsteroidDirection.X = (float)Math.Cos(Maths.ToRadians(this.AsteroidSprite.Rotation));
            AsteroidDirection.Y = (float)Math.Sin(Maths.ToRadians(this.AsteroidSprite.Rotation));

            if(AsteroidDirection.Length() > 0)
            {
                AsteroidDirection.Normalise();
            }
            
            this.AsteroidSprite.Position += AsteroidDirection * MovementSpeed;

            float Angle = (float)Math.Atan2((720 / 2) - this.AsteroidSprite.Position.Y, (1280 / 2) - this.AsteroidSprite.Position.X);
            Angle = Maths.ToDegrees(Angle);

            this.AsteroidSprite.Rotation = Angle;
            #endregion

            IntRect Rect = new IntRect((int)this.AsteroidSprite.Position.X, (int)this.AsteroidSprite.Position.Y, (int)this.AsteroidSprite.Texture.Size.X, (int)this.AsteroidSprite.Texture.Size.Y);

            for (int i = 0; i < Plr.Bullets.Count; i++)
            {
                if (Plr.Bullets[i] == null)
                    continue;

                Projectile Bullet = Plr.Bullets[i];
                

                if(Rect.Intersects(Bullet.Rect))
                {
                    Plr.Bullets[i].Die();
                    this.IsAlive = false;
                    Plr.AddPoints();
                }
            }

            if(Rect.Intersects(Plr.Rect))
            {
                Plr.Reset();
                this.NeedsReset = true;
            }
        }

        public bool IsAlive
        {
            get;
            private set;
        }

        public bool NeedsReset
        {
            get;
            private set;
        }

        private Texture AsteroidTexture;
        private Sprite AsteroidSprite;
        private float MovementSpeed;
    }
}
