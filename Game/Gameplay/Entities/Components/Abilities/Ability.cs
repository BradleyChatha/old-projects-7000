using SFML.Window;
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
            
        }

        public void Update(Entity Owner)
        {
            if(Keyboard.IsKeyPressed(ActivationKey) && this.CurrentCooldown <= 0)
            {
                this.OnUse(Owner);
                this.CurrentCooldown = this.Cooldown;
            }
            else
            {
                this.CurrentCooldown -= FPSCounter.DeltaTime;
            }
        }

        protected virtual void OnUse(Entity Owner)
        {

        }

        protected Keyboard.Key ActivationKey;
        protected float Cooldown; //How long it's on cool down for.
        protected float CurrentCooldown; //How long it has been on cool down for.
    }
}
