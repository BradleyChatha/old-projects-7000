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
            this.Angle = 0;
            this.AddNewComponent<TestSummon>();
            this.AddNewComponent<CameraComponent>();
            this.AddNewComponent<HealthComponent>();

            this.Get<CameraComponent>().SetWindowHandle(ref WindowHandle);
            this.Get<HealthComponent>().MaximumHealth = 250.0f;
            this.Get<HealthComponent>().ResetHealth();

            this.PlayerPet = null;
            this.WindowHandle = WindowHandle;
            this.DrawableSprite.Origin = new Vector2f(this.DrawableSprite.Texture.Size.X / 2, this.DrawableSprite.Texture.Size.Y / 2);

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

            Vector2f MousePosition = this.WindowHandle.WindowHandle.MapPixelToCoords(Mouse.GetPosition(this.WindowHandle.WindowHandle));
            this.Angle = (float)Math.Atan2(MousePosition.Y - this.Position.Y,
                                           MousePosition.X - this.Position.X);

            this.Angle *= (float)(180 / Math.PI);

            if(this.Angle < 0)
                this.Angle += 360;

            this.DrawableSprite.Rotation = this.Angle + 90;
        }

        public void SetPet(Pet PlayerPet)
        {
            this.PlayerPet = PlayerPet;
        }

        public override void Draw(DrawWindow Wnd)
        {
            base.Draw(Wnd);

            if(this.PlayerPet != null)
                this.PlayerPet.Draw(Wnd);
        }

        public float Angle
        {
            get;
            private set;
        }

        private DrawWindow WindowHandle;
        private Pet PlayerPet;
        private float MovementSpeed;
    }
}
