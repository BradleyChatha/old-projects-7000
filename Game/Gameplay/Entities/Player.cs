using System;
using SFML.Graphics;
using SFML.System;
using SFML.Window;
using Game.Engine;

namespace Game.Gameplay
{
    class Player : Entity
    {
        public Player(string PlayerPath, ref DrawWindow WindowHandle) : base(PlayerPath)
        {
            this.MovementSpeed = 250.0f;
            this.AddNewComponent<TestSummon>();
            this.AddNewComponent<CameraComponent>();
            this.Get<CameraComponent>().SetWindowHandle(ref WindowHandle);
            this.PlayerPet = null;
            this.WindowHandle = WindowHandle;

            Logger.Log(LogLevel.Info, "Created Player object");
        }

        public override void Update()
        {
            base.Update();
            this.Movement();

            if(this.PlayerPet != null)
                this.PlayerPet.Update(this);
        }

        private void Movement()
        {
            Vector2f OffsetUp = new Vector2f(0, this.MovementSpeed) * FPSCounter.DeltaTime;
            Vector2f OffsetSide = new Vector2f(this.MovementSpeed, 0) * FPSCounter.DeltaTime;

            if (Keyboard.IsKeyPressed(Keyboard.Key.W))
            {
                this.Move(-OffsetUp);
                this.Get<CameraComponent>().Move(-OffsetUp);
            }
            if (Keyboard.IsKeyPressed(Keyboard.Key.S))
            {
                this.Move(OffsetUp);
                this.Get<CameraComponent>().Move(OffsetUp);
            }

            if (Keyboard.IsKeyPressed(Keyboard.Key.A))
            {
                this.Move(-OffsetSide);
                this.Get<CameraComponent>().Move(-OffsetSide);
            }
            if (Keyboard.IsKeyPressed(Keyboard.Key.D))
            {
                this.Move(OffsetSide);
                this.Get<CameraComponent>().Move(OffsetSide);
            }
        }

        public void SetPet(Pet PlayerPet)
        {
            this.PlayerPet = PlayerPet;
        }

        public override void Draw(DrawWindow Wnd)
        {
            base.Draw(Wnd);

            Logger.Log(LogLevel.Debug, "override Player.Draw");

            if(this.PlayerPet != null)
                this.PlayerPet.Draw(Wnd);
        }

        private DrawWindow WindowHandle;
        private Pet PlayerPet;
        private float MovementSpeed;
    }
}
