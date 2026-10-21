using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using SFML.Graphics;
using SFML.System;
using RoyT.AStar;

namespace Game.Engine
{
    class Pathfinder
    {
        public Pathfinder(Vector2i Size)
        {
            this.PathfinderGrid = new Grid((int)(Size.X), (int)(Size.Y));
            this.PathPosition = 0;

            Logger.Log(LogLevel.Info, "Constructed new pathfinder.");
        }

        public void BlockCellsAt(Vector2i Position)
        {
            this.PathfinderGrid.BlockCell(new Position(Position.X, Position.Y));
        }

        public void SetCostAt(Vector2i Position, float Cost)
        {
            this.PathfinderGrid.SetCellCost(new Position(Position.X, Position.Y), Cost);
        }

        public void GetPathTo(Vector2i Source, Vector2i Destination)
        {
            Source = Source / Pathfinder.GridSize;
            Destination = Destination / Pathfinder.GridSize;

            this.Path = PathfinderGrid.GetPath(new Position(Source.X, Source.Y), new Position(Destination.X, Destination.Y), MovementPatterns.LateralOnly).Skip(1).ToArray();
            this.PathPosition = 0;
        }

        public Position? GetNext()
        {
            if(this.PathPosition < this.Path.Length)
                this.PathPosition += 1;

            if(this.Path.Length == 0)
                return null;

            return new Position(this.Path[this.PathPosition - 1].X * Pathfinder.GridSize, this.Path[this.PathPosition - 1].Y * Pathfinder.GridSize);
        }

        public bool IsAtEndOfPath
        {
            get
            {
                return this.PathPosition >= this.Path.Length;
            }
        }

        public Grid PathfinderGrid { get; private set; }
        private Position[] Path;
        private uint PathPosition;
        private const int GridSize = 32;
    }
}
