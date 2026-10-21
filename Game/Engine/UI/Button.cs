using System;
using SFML.Window;
using SFML.Graphics;
using SFML.System;

namespace Game.Engine
{
    class Button : UIElement
    {
        public Button(string ButtonPath, Vector2f Position, ref DrawWindow WindowHandle) : base(ButtonPath, ref WindowHandle)
        {

            this.HasBeenClicked = false;
            this.Position = Position;

            Logger.Log(LogLevel.Info, "Created a new button UI element");
        }

        public void AddEvents(OnClick ClickEvent, OnEnterHover HoverEnterEvent, OnLeaveHover HoverLeaveEvent)
        {
            this.ClickEvent = ClickEvent;
            this.HoverEnterEvent = HoverEnterEvent;
            this.HoverLeaveEvent = HoverLeaveEvent;
        }

        public void ChangeColour(Color NewColour)
        {
            this.DrawableSprite.Color = NewColour;
        }

        public void SetToDefaultColour()
        {
            this.DrawableSprite.Color = new Color(255, 255, 255);
        }

        public override void Update()
        {
            if(this.IsHoverOver())
            {
                if(!this.HasBeenHovered)
                { 
                    this.HoverEnterEvent();
                    this.HasBeenHovered = true;
                }

                if(Mouse.IsButtonPressed(Mouse.Button.Left) && !this.HasBeenClicked)
                {
                    this.ClickEvent();
                    this.HasBeenClicked = true;
                }

                if(!Mouse.IsButtonPressed(Mouse.Button.Left))
                    this.HasBeenClicked = false;
            }
            else if(!this.IsHoverOver() && this.HasBeenHovered)
            {
                this.HasBeenHovered = false;
                this.HoverLeaveEvent();
            }
        }

        private bool IsHoverOver()
        {
            Vector2f MousePosition = WindowHandle.WindowHandle.MapPixelToCoords(Mouse.GetPosition(WindowHandle.WindowHandle));

                   //Left                                   Right
            return ((MousePosition.X >= this.Position.X) && (MousePosition.X <= (this.Position.X + this.Size.X)) &&
                   //Top                                    Bottom
                    (MousePosition.Y >= this.Position.Y) && (MousePosition.Y <= (this.Position.Y + this.Size.Y)));
        }

        public delegate void OnClick();
        public delegate void OnEnterHover();
        public delegate void OnLeaveHover();

        private OnClick ClickEvent;
        private OnEnterHover HoverEnterEvent;
        private OnLeaveHover HoverLeaveEvent;
        private bool HasBeenClicked;
        private bool HasBeenHovered;
    }
}
