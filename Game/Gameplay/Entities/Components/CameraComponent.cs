using Game.Engine;
using SFML.Graphics;
using SFML.System;

namespace Game.Gameplay
{
    class CameraComponent : IComponent
    {
        public void Deinit()
        {
            
        }

        public void Init()
        {
            this.HasInit = false;
        }

        public void Update(Entity Owner)
        {
            if(!this.HasInit)
            {
                this.Camera = new View(new FloatRect(Owner.Position.X - (this.WindowHandle.WindowHandle.Size.X / 2), 
                                       Owner.Position.Y + -(this.WindowHandle.WindowHandle.Size.Y / 2),
                                       this.WindowHandle.WindowHandle.Size.X,
                                       this.WindowHandle.WindowHandle.Size.Y));
                this.HasInit = true;
            }

            this.WindowHandle.WindowHandle.SetView(this.Camera);
        }

        public void SetWindowHandle(ref DrawWindow WindowHandle)
        {
            this.WindowHandle = WindowHandle;
        }

        public void Move(Vector2f Offset)
        {
            this.Camera.Move(Offset);
        }

        private View Camera;
        private DrawWindow WindowHandle;
        private bool HasInit;
    }
}
