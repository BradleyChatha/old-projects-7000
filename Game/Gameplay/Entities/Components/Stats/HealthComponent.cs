using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Game.Gameplay
{
    class HealthComponent : IComponent
    {
        public void Init()
        {
            this.MaximumHealth = 0;
            this.HealthValue = 0;
        }

        public void Deinit()
        {
        }

        public void Update(Entity Owner)
        {
        }

        public bool IsDead
        {
            get
            {
                return this.HealthValue <= 0.0f;
            }
        }

        public void DecreaseHealth(float Amount = 10.0f)
        {
            this.HealthValue -= Amount;

            if(this.HealthValue < 0.0f)
                this.HealthValue = 0.0f;
        }

        public void IncreaseHealth(float Amount = 10.0f)
        {
            this.HealthValue += Amount;

            if(this.HealthValue > this.MaximumHealth)
                this.HealthValue = this.MaximumHealth;
        }

        public void ResetHealth()
        {
            this.HealthValue = this.MaximumHealth;
        }

        public float MaximumHealth
        {
            get;
            set;
        }

        public float HealthValue
        {
            get;
            private set;
        }
    }
}
