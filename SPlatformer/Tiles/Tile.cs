using SFML.Graphics;
using SFML.System;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SPlatformer
{
    public enum TileID
    {
        Platform = 0,
        SpawnPoint,
        EndPoint,

        TotalTiles
    }

    public static class TileInfo
    {
        public readonly static int TileHeight = 32; ///In PX
        public readonly static int TileSize = (TileHeight * TileHeight);
    }

    public abstract class Tile
    {
        public Tile()
        {
        }

        public Tile(string TexturePath)
        {
            this.TileTexture = new Texture(TexturePath);
            this.TileSprite = new Sprite(this.TileTexture);
            this.CanCollide = true;
        }

        public TileID ID
        {
            get;
            protected set;
        }

        public void Draw(RenderWindow Wnd)
        {
            Wnd.Draw(this.TileSprite);
        }

        public void SetPositionByCell(Vector2f Cell)
        {
            this.TileSprite.Position = this.FromCellToWorldPosition(Cell);
        }

        public Vector2f FromWorldPositionToCell(Vector2f WorldPosition)
        {
            return new Vector2f(WorldPosition.X / TileInfo.TileHeight, WorldPosition.Y / TileInfo.TileHeight);
        }

        public Vector2f FromCellToWorldPosition(Vector2f Cell)
        {
            return new Vector2f(Cell.X * TileInfo.TileHeight, Cell.Y * TileInfo.TileHeight);
        }

        public virtual void Update(float dt, Player Plr)
        {
        }

        public Vector2i Cell
        {
            get { return new Vector2i((int)Math.Floor(this.TileSprite.Position.X / this.TileTexture.Size.X), (int)Math.Floor(this.TileSprite.Position.Y / this.TileTexture.Size.Y)); }
        }

        public FloatRect Rect
        {
            get { return new FloatRect(this.TileSprite.Position.X, this.TileSprite.Position.Y, this.TileTexture.Size.X, this.TileTexture.Size.Y); }
        }

        public bool CanCollide
        {
            get;
            protected set;
        }

        protected Texture TileTexture;
        protected Sprite TileSprite;
    }
}