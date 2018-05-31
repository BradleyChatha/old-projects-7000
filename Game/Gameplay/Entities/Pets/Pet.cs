using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using RoyT.AStar;
using SFML.System;
using SFML.Window;
using Game.Engine;

namespace Game.Gameplay
{
    class Pet : Entity
    {
        public Pet(string PetPath, Player Owner) : base(PetPath)
        {
            this.Pathfinding = new Pathfinder(new Vector2i(100, 100));
            this.NextPosition = new Vector2f(0, 0);
            this.Percentage = 0;
            this.MovementSpeed = 2f;
            this.Pathfinding.GetPathTo(new Vector2i((int)this.Position.X, (int)this.Position.Y) / 32, new Vector2i((int)Owner.Position.X, (int)Owner.Position.Y) / 32);
            this.NextCell = this.Pathfinding.GetNext();
            this.LastOwnerPosition = Owner.Position;

            Logger.Log(LogLevel.Debug, "Created new base Pet");
        }

        public void Update(Entity Owner)
        {
            this.CalculatePath(Owner);
            this.FollowOwner();
        }

        public void CalculatePath(Entity Owner)
        {
            if (Owner.Position != this.LastOwnerPosition)
            {
                Pathfinding.GetPathTo(new Vector2i((int)this.Position.X, (int)this.Position.Y), new Vector2i((int)Owner.Position.X, (int)Owner.Position.Y));
                this.LastOwnerPosition = Owner.Position;
            }
        }

        public void FollowOwner()
        {
            if(this.Percentage >= 1.0f)
            {
                this.Percentage = 0;
                this.NextCell = this.Pathfinding.GetNext();
                this.LerpStartPosition = this.Position;
            }

            this.Percentage += MovementSpeed * FPSCounter.DeltaTime;

            if(this.NextCell != null)
                this.Position = VectorMaths.Lerp(this.LerpStartPosition, new Vector2f(this.NextCell.GetValueOrDefault().X, this.NextCell.GetValueOrDefault().Y), this.Percentage);
        }

        private Pathfinder Pathfinding;
        private Vector2f NextPosition;
        private float Percentage;
        private float MovementSpeed;
        private Position? NextCell;
        private Vector2f LerpStartPosition;
        private Vector2f LastOwnerPosition;
    }
}
