using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Game.Gameplay
{
    class PlayerBasicAttackComponent : Ability
    {
        override public void Init()
        {
            base.Init();

            this.CastTime = 0.0f;
            this.Cooldown = 0.15f;

            this.ActivationKey = SFML.Window.Keyboard.Key.Space;
        }

        protected override void OnUse(Entity Owner)
        {
            
        }
        
        private List<BasicAttackProjectile> Projectiles;
    }
}
