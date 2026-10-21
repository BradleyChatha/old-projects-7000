using SFML.Graphics;
using SFML.System;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using SFMLHelper;

namespace Asteroids
{
    public class Projectile
    {
        public Projectile(Vector2f SpawnPosition, float Rot)
        {
            Random ColourPicker = new Random();

            this.Bullet = new RectangleShape(Size)
            {
                Position = SpawnPosition,
                FillColor = new Color((byte)ColourPicker.Next(255), (byte)ColourPicker.Next(255), (byte)ColourPicker.Next(255)),
                OutlineColor = Color.Black,
                OutlineThickness = 1,
                Rotation = Rot
            };

            this.MovementSpeed = 3;
            this.IsAlive = true;
        }

        public void Update()
        {
            Vector2f BulletDirection = new Vector2f(0, 0);

            BulletDirection.X = (float)Math.Cos(Maths.ToRadians(this.Bullet.Rotation + -90));
            BulletDirection.Y = (float)Math.Sin(Maths.ToRadians(this.Bullet.Rotation + -90));

            if(BulletDirection.Length() > 0)
            {
                BulletDirection = BulletDirection.Normalise();
            }

            this.Bullet.Position += BulletDirection * MovementSpeed;

            if (this.IsOutOfWindow())
                this.IsAlive = false;
        }

        public void Draw(RenderWindow Wnd)
        {
            Wnd.Draw(this.Bullet);

            var shape = new RectangleShape();
            shape.Position = new Vector2f(this.Rect.Left, this.Rect.Top);
            shape.Size = new Vector2f(this.Rect.Width, this.Rect.Height);

            shape.FillColor = Color.Transparent;
            shape.OutlineColor = Color.Red;
            shape.OutlineThickness = 3;

            Wnd.Draw(shape);
        }

        public bool IsOutOfWindow()
        {
            if ((this.Bullet.Position.X + this.Bullet.Size.X) > 1280 || (this.Bullet.Position.X + this.Bullet.Size.X) < 0)
                return true;

            if ((this.Bullet.Position.Y + this.Bullet.Size.Y) > 720 || (this.Bullet.Position.Y + this.Bullet.Size.Y) < 0)
                return true;

            return false;
        }

        public void Die()
        {
            this.IsAlive = false;
        }

        public static Vector2f Size 
        {
            get
            {
                return new Vector2f(5, 30);
            }
        }

        public IntRect Rect
        {
            get
            {
                return new IntRect((int)this.Bullet.Position.X, (int)this.Bullet.Position.Y, (int)this.Bullet.Size.X, (int)this.Bullet.Size.Y);
            }
        }

        public bool IsAlive
        {
            get;
            private set;
        }

        private float MovementSpeed;
        private RectangleShape Bullet;
    }
}
