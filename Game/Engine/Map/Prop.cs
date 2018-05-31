using SFML.System;

namespace Game.Engine
{
    /// <summary>
    /// The base prop.
    /// </summary>
    public class Prop : Drawable
    {
        public Prop(string PropPath, Vector2f Position) : base(PropPath)
        {
            this.DoesUpdate = false;
            this.Position = Position;
        }

        public bool IsPropAtLocation(Vector2f Position)
        {
            return this.Box.Contains(Position.X, Position.Y);
        }
    }
}
