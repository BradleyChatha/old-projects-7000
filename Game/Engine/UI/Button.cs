using System;
using SFML.Window;
using SFML.Graphics;
using SFML.System;

namespace Game.Engine
{
    class Button : UIElement
    {
        public Button(string ButtonPath, OnClick ClickEvent, OnHover HoverEvent, ref DrawWindow WindowHandle) : base(ButtonPath, ref WindowHandle)
        {
            this.ClickEvent = ClickEvent;
            this.HoverEvent = HoverEvent;
            this.HasBeenClicked = false;

            Logger.Log(LogLevel.Info, "Created a new button UI element");
        }

        public override void Update()
        {
            if(IsHoverOver())
            {
                this.HoverEvent();

                if(Mouse.IsButtonPressed(Mouse.Button.Left) && !this.HasBeenClicked)
                {
                    this.ClickEvent();
                    this.HasBeenClicked = true;
                }

                if(!Mouse.IsButtonPressed(Mouse.Button.Left))
                    this.HasBeenClicked = false;
            }
        }

        private bool IsHoverOver()
        {
            Vector2i MousePosition = Mouse.GetPosition(this.WindowHandle.WindowHandle);

            return (MousePosition.X <= (int)this.Size.X + (int)this.Position.X 
                    && MousePosition.Y <= (int)this.Size.Y + (int)this.Position.Y 
                    && MousePosition.X >= (int)this.Position.X 
                    && MousePosition.Y >= (int)this.Position.Y);
        }

        public delegate void OnClick();
        public delegate void OnHover();

        private OnClick ClickEvent;
        private OnHover HoverEvent;
        private bool HasBeenClicked;
    }
}
