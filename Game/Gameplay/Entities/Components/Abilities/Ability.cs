using SFML.Window;
using SFML.System;
using Game.Engine;

namespace Game.Gameplay
{
    class Ability : IComponent
    {
        public void Deinit()
        {
            
        }

        public virtual void Init()
        {
            this.CurrentCooldown = 0.0f;
            this.CurrentCastTime = 0.0f;
            this.IsCasting = false;
        }

        public void Update(Entity Owner)
        {
            if (this.IsOnCooldown)
            {
                this.CurrentCooldown -= FPSCounter.DeltaTime;
                return;
            }

            if (Keyboard.IsKeyPressed(ActivationKey) && !this.IsOnCooldown && !this.IsCasting)
            {
                ///Start the cast
                this.IsCasting = true;
                this.OwnerCastingPosition = Owner.Position;
                Logger.Log(LogLevel.Debug, "Starting to cast ability");
                return;
            }

            if (this.IsCasting)
            {
                if((Owner.Position == this.OwnerCastingPosition || this.CanMoveWhileCasting) && this.CurrentCastTime < this.CastTime)
                {
                    this.CurrentCastTime += FPSCounter.DeltaTime;
                }
                else if((Owner.Position == this.OwnerCastingPosition || this.CanMoveWhileCasting) && this.CurrentCastTime >= this.CastTime)
                {
                    this.OnUse(Owner);
                    this.CurrentCooldown = this.Cooldown;
                    this.CurrentCastTime = 0;
                    this.IsCasting = false;
                    Logger.Log(LogLevel.Debug, "Finished casting ability");
                }
                else
                {
                    Logger.Log(LogLevel.Info, "Player has moved, aborting the cast");
                    this.IsCasting = false;
                    this.CurrentCastTime = 0;
                }
            }
        }

        protected virtual void OnUse(Entity Owner)
        {

        }

        public float CastTime //How long it takes to cast
        {
            get;
            protected set;
        }

        public float CurrentCastTime //How long it's been casting for
        {
            get;
            protected set;
        }

        public bool IsCasting //Is the ability being cast currently?
        {
            get;
            protected set;
        }

        public float Cooldown //How long it's on cool down for.
        {
            get;
            protected set;
        }

        public float CurrentCooldown //How long it has been on cool down for.
        {
            get;
            protected set;
        }

        public bool IsOnCooldown //Is the ability currently on cooldown?
        {
            get
            {
                return (this.CurrentCooldown < 0);
            }
        }

        public bool CanMoveWhileCasting
        {
            get;
            protected set;
        }

        protected Keyboard.Key ActivationKey;
        protected Vector2f OwnerCastingPosition; //The position of the player when they first started casting the ability.
    }
}
