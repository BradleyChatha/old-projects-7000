using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SPlatformer
{
    public class PlayerSpawn : Tile
    {
        public PlayerSpawn() : base("Assets\\Spawn.png")
        {
            this.ID = TileID.SpawnPoint;
            this.CanCollide = false;
        }
    }
}
