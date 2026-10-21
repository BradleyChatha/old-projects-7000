
namespace Game.Gameplay
{
    interface IComponent
    {
        void Init();
        void Deinit();
        void Update(Entity Owner);
    }
}
