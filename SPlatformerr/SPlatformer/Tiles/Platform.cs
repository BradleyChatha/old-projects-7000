using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SPlatformer
{
    public class Platform : Tile
    {
        public Platform() : base("Assets\\Platform.png")
        {
            this.ID = TileID.Platform;
        }
    }
}
