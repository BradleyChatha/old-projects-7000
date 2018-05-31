using SFML.Window;
using Game.Engine;

namespace Game.Gameplay
{
    class TestSummon : Ability
    {
        override public void Init()
        {
            Logger.Log(LogLevel.Debug, "Called new TestSummon.Init");
            this.Cooldown = 3.0f;
            this.CurrentCooldown = 0.0f;
            this.ActivationKey = Keyboard.Key.Num1;
        }

        protected override void OnUse(Entity Owner)
        {
            Logger.Log(LogLevel.Debug, "Called TestSummon");
            ((Player)Owner).SetPet(new Pet("PetTest.png", (Player)Owner));
        }
    }
}
