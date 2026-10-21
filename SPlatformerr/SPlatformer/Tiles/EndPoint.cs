using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SPlatformer
{
    public class EndPoint : Tile
    {
        public delegate void OnNextLevelNeeded(Player Plr);

        public EndPoint(OnNextLevelNeeded LevelLoader) : base("Assets\\End.png")
        {
            this.Loader = LevelLoader;
            this.ID = TileID.EndPoint;
        }
        
        public override void Update(float dt, Player Plr)
        {
            if (Plr.IsCollidingWith(this))
                this.Loader(Plr);
        }

        private OnNextLevelNeeded Loader;
    }
}
