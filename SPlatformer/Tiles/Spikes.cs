using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SPlatformer
{
    public class Spikes : Tile
    {
        public delegate void ResetFunc(Player Plr);

        public Spikes(ResetFunc ResetCallback) : base("Assets\\Spikes.png")
        {
            this.ID = TileID.Spikes;
            this.Reset = ResetCallback;
        }

        public override void Update(float dt, Player Plr)
        {
            if (Plr.IsCollidingWith(this))
                this.Reset(Plr);
        }

        private ResetFunc Reset;
    }
}
