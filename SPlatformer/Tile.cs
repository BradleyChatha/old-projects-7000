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

        TotalTiles
    }

    public static class TileInfo
    {
        public readonly static int TileHeight = 32; ///In PX
        public readonly static int TileSize = (TileHeight * TileHeight);
    }

    public class Tile
    {
        public Tile(TileID ID, )
        {
            this.TileTexture = new Texture(TexturePath);
            this.TileSprite = new Sprite(this.TileTexture);
        }

        public uint ID
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
            this.TileSprite.Position = new Vector2f(Cell.X * TileInfo.TileHeight, Cell.Y * TileInfo.TileHeight);
        }

        public Vector2f FromWorldPositionToCell(Vector2f WorldPosition)
        {
            return new Vector2f(WorldPosition.X * TileInfo.TileHeight, WorldPosition.Y * TileInfo.TileHeight);
        }

        public void Update(float dt)
        {
        }

        protected Texture TileTexture;
        protected Sprite TileSprite;
    }
}