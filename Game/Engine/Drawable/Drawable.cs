using System;
using System.IO;
using SFML.Graphics;
using SFML.System;

namespace Game.Engine
{
    public class Drawable
    {
        public Drawable(string TexturePath)
        {
            try
            {
                this.DrawableTexture = new Texture(TexturePath);
                this.DrawableSprite = new Sprite(this.DrawableTexture);
            }
            catch(Exception e)
            {
                Logger.Log(LogLevel.Error, $"Failed to load the texture. Exception = {e.Message}");
                Logger.Deinit();
                Environment.Exit(-1);
            }

            this.DoesUpdate = true;

            Logger.Log(LogLevel.Info, $"Loaded texture: {Path.GetFileName(TexturePath)}");
        }

        public virtual void Draw(DrawWindow Wnd)
        {
            Wnd.WindowHandle.Draw(this.DrawableSprite);
        }

        public virtual void Update()
        {}

        public void Move(Vector2f Offset)
        {
            this.DrawableSprite.Position += Offset;
        }

        public Vector2f Position
        {
            get
            {
                return this.DrawableSprite.Position;
            }
            set
            {
                this.DrawableSprite.Position = value;
            }
        }

        public Vector2f Origin
        {
            get
            {
                return this.DrawableSprite.Origin;
            }
            set
            {
                this.DrawableSprite.Origin = value;
            }
        }

        public Vector2u Size
        {
            get
            {
                return this.DrawableTexture.Size;
            }
        }

        public FloatRect Box
        {
            get
            {
                return this.DrawableSprite.GetGlobalBounds();
            }
        }

        public Sprite DrawableSprite { get; protected set; }
        public bool DoesUpdate { get; protected set; }
        protected Texture DrawableTexture;
    }
}
